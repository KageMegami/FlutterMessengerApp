import {
  Controller,
  Request,
  Post,
  UseGuards,
  Body,
  Get,
} from '@nestjs/common';
import { FirebaseAuthGuard } from 'src/auth/firebase-auth.guard';
import { Conversation } from 'src/messages/entity/conversation.entity';
import { FriendRequest } from '../entity/friendRequest.entity';
import { User } from '../entity/user.entity';
import { CreateUserRequestDto } from '../model/CreateUserRequest.dto';
import { FriendRequestDto } from '../model/FriendRequest.dto';
import { FriendRequestAnswerDto } from '../model/FriendRequestAnswer.dto';
import { FriendRequestResultDto } from '../model/FriendRequestResult.dto';
import { SearchRequestDto } from '../model/SearchRequest.dto';
import { UpdateTokenDto } from '../model/UpdateToken.dto';
import { UpdateUserRequestDto } from '../model/UpdateUserRequest.dto';
import { UsersService } from '../service/users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) { }

  @Get()
  @UseGuards(FirebaseAuthGuard)
  public async getUserInfo(@Request() req) {
    return await this.usersService.getById(
      await this.usersService.getIdFromIdAuth(req.user),
    );
  }

  @Post()
  @UseGuards(FirebaseAuthGuard)
  public async registerUser(
    @Request() req,
    @Body() createUserRequestDto: CreateUserRequestDto,
  ): Promise<User> {
    return await this.usersService.registerUser(req.user, createUserRequestDto);
  }

  @Post('update')
  @UseGuards(FirebaseAuthGuard)
  public async updateProfile(
    @Request() req,
    @Body() updateUserRequestDto: UpdateUserRequestDto,
  ): Promise<User> {
    return await this.usersService.updateUser(req.user, updateUserRequestDto);
  }

  @Post('token')
  @UseGuards(FirebaseAuthGuard)
  public async setFCMToken(
    @Request() req,
    @Body() updateTokenDto: UpdateTokenDto,
  ): Promise<User> {
    return await this.usersService.setFCMToken(req.user, updateTokenDto);
  }

  @Post('search')
  @UseGuards(FirebaseAuthGuard)
  public async searchUser(
    @Request() req,
    @Body() searchRequestDto: SearchRequestDto,
  ): Promise<User[]> {
    return await this.usersService.searchUser(searchRequestDto);
  }

  @Get('conversations')
  @UseGuards(FirebaseAuthGuard)
  public async getConversations(@Request() req): Promise<Conversation[]> {
    return await this.usersService.getConversations(
      await this.usersService.getIdFromIdAuth(req.user),
    );
  }

  @Get('friends')
  @UseGuards(FirebaseAuthGuard)
  public async getFriends(@Request() req): Promise<User[]> {
    return await this.usersService.getFriends(
      await this.usersService.getIdFromIdAuth(req.user),
    );
  }

  @Get('friends/requests')
  @UseGuards(FirebaseAuthGuard)
  public async getFriendRequest(
    @Request() req,
  ): Promise<FriendRequestResultDto[]> {
    return await this.usersService.getFriendRequest(
      await this.usersService.getIdFromIdAuth(req.user),
    );
  }

  @Post('friends/requests')
  @UseGuards(FirebaseAuthGuard)
  public async sendFriendRequest(
    @Request() req,
    @Body() friendRequestDto: FriendRequestDto,
  ): Promise<FriendRequest> {
    return await this.usersService.sendFriendRequest(
      await this.usersService.getIdFromIdAuth(req.user),
      friendRequestDto,
    );
  }

  @Post('friends/requests/answer')
  @UseGuards(FirebaseAuthGuard)
  public async answerFriendRequest(
    @Request() req,
    @Body() friendRequestAnswerDto: FriendRequestAnswerDto,
  ): Promise<void> {
    return await this.usersService.answerFriendRequest(
      await this.usersService.getIdFromIdAuth(req.user),
      friendRequestAnswerDto,
    );
  }
}
