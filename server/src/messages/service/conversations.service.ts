import {
  forwardRef,
  Inject,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { UsersService } from 'src/users/service/users.service';
import { Conversation } from '../entity/conversation.entity';
import { Message } from '../entity/message.entity';
import { CreateConversationRequestDto } from '../model/conversation/CreateConversationRequest.dto';
import { ConversationRepository } from '../repository/conversation.repository';
import * as firebase from 'firebase-admin';

@Injectable()
export class ConversationsService {
  constructor(
    private readonly repository: ConversationRepository,
    @Inject(forwardRef(() => UsersService))
    private readonly userService: UsersService,
  ) { }

  public async checkRightReadWriteConversation(
    authId: string,
    conversationId: string,
  ): Promise<string> {
    const userId = await this.userService.getIdFromIdAuth(authId);
    const allowedUser = await this.getConversationUsers(conversationId);
    if (!allowedUser.includes(userId)) {
      throw new UnauthorizedException(
        'You are not allowed to read this ressource',
      );
    }
    return userId;
  }

  public async getAll(): Promise<Conversation[]> {
    return await this.repository.find();
  }

  public async getById(id: string): Promise<Conversation> {
    return await this.repository.findOne({ id });
  }

  public async getConversationUsers(id: string): Promise<string[]> {
    const conversation = await this.repository.findOne({
      relations: ['users'],
      where: { id },
    });
    if (conversation === undefined) {
      throw new NotFoundException('This conversation does not exist.');
    }
    const users = conversation.users;
    return users.map((user) => user.id);
  }

  public async getConversationMessage(
    conversationiId: string,
    idAuth: string,
  ): Promise<Message[]> {
    await this.checkRightReadWriteConversation(idAuth, conversationiId);
    const conversation = await this.repository.findOne({
      relations: ['messages'],
      where: { id: conversationiId },
    });
    return conversation.messages;
  }

  public async create(
    createConversationRequestDto: CreateConversationRequestDto,
    isGroup: boolean,
  ): Promise<Conversation> {
    const users = await Promise.all(
      createConversationRequestDto.users.map(
        async (userId) => await this.userService.getById(userId),
      ),
    );
    const conversation = this.repository.save({
      name: createConversationRequestDto.name,
      users,
      isGroup,
    });
    return conversation;
  }

  public async notifyUsers(message: Message, conversationId: string) {
    const conversation = await this.getById(conversationId);
    const sender = await this.userService.getById(message.sender_id);
    const userIDs = await this.getConversationUsers(conversationId);
    const users = await Promise.all(
      userIDs.map(async (id: string) => await this.userService.getById(id)),
    );
    firebase.messaging().sendMulticast({
      tokens: users.map((user) => user.FCM_token).filter((val) => val !== null),
      data: {
        type: 'message',
        content: message.content,
        conversationId: conversationId,
        senderId: message.sender_id,
        id: message.id,
        date: message.createdDate.toUTCString(),
      },
      notification: {
        title: conversation.name,
        body: sender.firstName + ' ' + sender.lastName + ': ' + message.content,
      },
      android: {
        priority: 'high',
      },
    });
  }
}
