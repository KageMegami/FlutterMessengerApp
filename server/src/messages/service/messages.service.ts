import { Injectable } from '@nestjs/common';
import { Message } from '../entity/message.entity';
import { SendMessageRequestDto } from '../model/message/SendMessageRequest.dto';
import { MessageRepository } from '../repository/message.repository';
import { ConversationsService } from './conversations.service';

@Injectable()
export class MessagesService {
  constructor(
    private readonly messageRepository: MessageRepository,
    private readonly conversationsService: ConversationsService,
  ) { }

  public async addMessage(
    sendMessageRequestDto: SendMessageRequestDto,
    userId: string,
  ): Promise<Message> {
    const conversation = await this.conversationsService.getById(
      sendMessageRequestDto.conversation_id,
    );
    const sender =
      await this.conversationsService.checkRightReadWriteConversation(
        userId,
        sendMessageRequestDto.conversation_id,
      );
    const new_message = this.messageRepository.create({
      conversation,
      content: sendMessageRequestDto.content,
      sender_id: sender,
    });
    const savedMessage = await this.messageRepository.save(new_message);
    this.conversationsService.notifyUsers(savedMessage, sendMessageRequestDto.conversation_id);
    return savedMessage;
  }
}
