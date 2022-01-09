import {
  ConflictException,
  forwardRef,
  Inject,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { Conversation } from 'src/messages/entity/conversation.entity';
import * as firebase from 'firebase-admin';
import { ConversationsService } from 'src/messages/service/conversations.service';
import { FriendRequest } from '../entity/friendRequest.entity';
import { User } from '../entity/user.entity';
import { CreateUserRequestDto } from '../model/CreateUserRequest.dto';
import { FriendRequestDto } from '../model/FriendRequest.dto';
import { FriendRequestAnswerDto } from '../model/FriendRequestAnswer.dto';
import { FriendRequestResultDto } from '../model/FriendRequestResult.dto';
import { SearchRequestDto } from '../model/SearchRequest.dto';
import { UpdateTokenDto } from '../model/UpdateToken.dto';
import { UpdateUserRequestDto } from '../model/UpdateUserRequest.dto';
import { FriendRequestRepository } from '../repository/friendRequest.repository';
import { UserRepository } from '../repository/user.repository';

@Injectable()
export class UsersService {
  constructor(
    private readonly repository: UserRepository,
    private readonly friendRequestRepository: FriendRequestRepository,
    @Inject(forwardRef(() => ConversationsService))
    private readonly conversationService: ConversationsService,
  ) { }

  public async getAll(): Promise<User[]> {
    return await this.repository.find();
  }

  public async getById(id: string): Promise<User> {
    return await this.repository.findById(id);
  }

  public async getIdFromIdAuth(idAuth: string) {
    const user = await this.repository.findByIdAuth(idAuth);
    if (user === undefined) {
      throw new NotFoundException('User not found.');
    }
    return user.id;
  }

  public async registerUser(
    idAuth: string,
    createUserRequestDto: CreateUserRequestDto,
  ): Promise<User> {
    const existingUser = await this.repository.findByIdAuth(idAuth);
    if (existingUser !== undefined) {
      throw new ConflictException(
        'Cannot create a new user because there already is a user with the same id',
      );
    }
    let newUser: User = this.repository.create({
      id_auth: idAuth,
      ...createUserRequestDto,
    });
    newUser = await this.repository.save(newUser);
    await this.conversationService.create(
      { name: 'Me', users: [newUser.id] },
      null,
    );
    return newUser;
  }

  public async updateUser(
    idAuth: string,
    updateUserRequestDto: UpdateUserRequestDto,
  ): Promise<User> {
    const existingUser = await this.repository.findByIdAuth(idAuth);
    if (existingUser == undefined) {
      throw new NotFoundException('Cannot find the user');
    }
    existingUser.firstName = updateUserRequestDto.firstName;
    existingUser.lastName = updateUserRequestDto.lastName;
    existingUser.url_picture = updateUserRequestDto.url_picture;
    return await this.repository.save(existingUser);
  }

  public async getConversations(userId: string): Promise<Conversation[]> {
    const user = await this.repository
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.conversations', 'conversation')
      .where('user.id = :id', { id: userId })
      .getOne();

    const currentUser = await this.getById(userId);

    //get the right name and picture to diplay for conversation
    return await Promise.all(
      user.conversations.map(async (conversation) => {
        if (conversation.isGroup === null || conversation.isGroup === true) {
          if (conversation.isGroup == null) {
            conversation.url_picture = currentUser.url_picture;
          }
          return conversation;
        }
        const users = await this.conversationService.getConversationUsers(
          conversation.id,
        );
        if (users.length < 2) {
          return conversation;
        }
        const userId = users.filter((id) => id != user.id)[0];
        const finalUser = await this.getById(userId);
        conversation.name = finalUser.firstName + ' ' + finalUser.lastName;
        conversation.url_picture = finalUser.url_picture;
        return conversation;
      }),
    );
  }

  public async setFCMToken(
    idAuth: string,
    updateTokenDto: UpdateTokenDto,
  ): Promise<User> {
    const existingUser = await this.repository.findByIdAuth(idAuth);
    if (existingUser == undefined) {
      throw new NotFoundException('Cannot find the user');
    }
    existingUser.FCM_token = updateTokenDto.token;
    return await this.repository.save(existingUser);
  }

  async getFriends(userId: string): Promise<User[]> {
    return await this.repository.query(
      ` SELECT * 
        FROM "user" U
        WHERE U."id" <> $1
          AND EXISTS(
            SELECT 1
            FROM "user_friends_user" F
            WHERE (F."userId_1" = $1 AND F."userId_2" = U."id" )
            OR (F."userId_2" = $1 AND F."userId_1" = U."id" )
            );  `,
      [userId],
    );
  }

  public async getFriendRequest(
    userId: string,
  ): Promise<FriendRequestResultDto[]> {
    const requests = await this.friendRequestRepository.getByTargetAndOpenTrue(
      userId,
    );

    return await Promise.all(
      requests.map(async (request) => {
        const user = await this.repository.findById(request.sender);
        return { id: request.id, user };
      }),
    );
  }

  public async sendFriendRequest(
    userId: string,
    friendRequestDto: FriendRequestDto,
  ): Promise<FriendRequest> {
    if (userId === friendRequestDto.userId) {
      throw new ConflictException('You cannot send friend request to yourself');
    }
    const sender = await this.repository.findById(userId);

    const target = await this.repository.findById(friendRequestDto.userId);
    if (target === undefined) {
      throw new NotFoundException('The user does not exist');
    }

    const friends = await this.getFriends(userId);
    if (friends.filter((u) => u.id === friendRequestDto.userId).length !== 0) {
      throw new ConflictException('The two users are already friends');
    }

    let request = this.friendRequestRepository.create({
      sender: userId,
      target: friendRequestDto.userId,
      open: true,
    });
    request = await this.friendRequestRepository.save(request);

    firebase.messaging().send({
      token: target.FCM_token,
      data: {
        type: 'friendRequest',
      },
      notification: {
        title: 'New friend request',
        body:
          sender.firstName +
          ' ' +
          sender.lastName +
          ' sent you a friend request',
      },
      android: {
        priority: 'high',
      },
    });

    return request;
  }

  public async answerFriendRequest(
    userId: string,
    friendRequestAnswerDto: FriendRequestAnswerDto,
  ): Promise<void> {
    const request = await this.friendRequestRepository.findById(
      friendRequestAnswerDto.requestId,
    );
    if (request === undefined) {
      throw new NotFoundException('This friend request does not exist');
    }
    if (request.target !== userId) {
      throw new UnauthorizedException(
        'You are not allowed to anwser this request',
      );
    }

    request.open = false;
    this.friendRequestRepository.save(request);
    if (friendRequestAnswerDto.response === 'true') {
      this.addFriends(request.sender, request.target);
    }
  }

  private async addFriends(userId1: string, userId2: string): Promise<void> {
    if (userId1 === userId2) {
      throw new ConflictException('You cannot be friend with yourself');
    }

    const user1 = await this.repository.findById(userId1);
    const user2 = await this.repository.findById(userId2);
    if (user1 === undefined || user2 === undefined) {
      throw new NotFoundException('The user does not exist');
    }

    const friends = await this.getFriends(userId1);

    if (friends.filter((user) => user.id === userId2).length !== 0) {
      throw new ConflictException('The two users are already friends');
    }
    friends.push(user2);
    user1.friends = friends;
    this.repository.save(user1);
    await this.conversationService.create(
      {
        name: user1.firstName + ' ' + user2.firstName,
        users: [user1.id, user2.id],
      },
      false,
    );
    firebase.messaging().send({
      token: user1.FCM_token,
      data: {
        type: 'friend',
      },
      notification: {
        title: 'New friend',
        body:
          user2.firstName +
          ' ' +
          user2.lastName +
          ' accepted your friend request',
      },
      android: {
        priority: 'high',
      },
    });
  }

  public async searchUser(searchRequestDto: SearchRequestDto): Promise<User[]> {
    const splitted = searchRequestDto.query
      .toLowerCase()
      .trim()
      .split(' ')
      .filter((str) => str.length !== 0);

    if (splitted.length === 1) {
      return await this.repository
        .createQueryBuilder('user')
        .where('LOWER(user.firstName) like :str', { str: `%${splitted[0]}%` })
        .orWhere('LOWER(user.lastName) like :str', { str: `%${splitted[0]}%` })
        .limit(10)
        .getMany();
    }

    if (splitted.length !== 2) {
      return [];
    }
    const firstBatch = await this.repository
      .createQueryBuilder('user')
      .where('LOWER(user.firstName) like :str1', {
        str1: `%${splitted[0]}%`,
      })
      .andWhere('LOWER(user.lastName) like :str2', {
        str2: `%${splitted[1]}%`,
      })
      .limit(10)
      .getMany();
    const secondBatch = await this.repository
      .createQueryBuilder('user')
      .where('LOWER(user.firstName) like :str1', {
        str1: `%${splitted[1]}%`,
      })
      .andWhere('LOWER(user.lastName) like :str2', {
        str2: `%${splitted[0]}%`,
      })
      .limit(10)
      .getMany();
    return firstBatch.concat(secondBatch);
  }
}
