import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { FirebaseAuthGuard } from 'src/auth/firebase-auth.guard';
import { Conversation } from '../entity/conversation.entity';
import { Message } from '../entity/message.entity';
import { CreateConversationRequestDto } from '../model/conversation/CreateConversationRequest.dto';
import { ConversationsService } from '../service/conversations.service';

@Controller('conversations')
export class ConversationsController {
  constructor(private readonly conversationService: ConversationsService) { }

  @Post()
  @UseGuards(FirebaseAuthGuard)
  public async createConversation(
    @Body() createConversationRequestDto: CreateConversationRequestDto,
  ): Promise<Conversation> {
    return await this.conversationService.create(
      createConversationRequestDto,
      true,
    );
  }

  @Get()
  @UseGuards(FirebaseAuthGuard)
  public async getConversations(): Promise<Conversation[]> {
    return await this.conversationService.getAll();
  }

  //not usefull but I keep it for now
  @Get(':id/users')
  @UseGuards(FirebaseAuthGuard)
  public async getConversationUsers(
    @Param('id') id: string,
  ): Promise<string[]> {
    return await this.conversationService.getConversationUsers(id);
  }

  @Get(':id/messages')
  @UseGuards(FirebaseAuthGuard)
  public async getConversationMessage(
    @Request() req,
    @Param('id') id: string,
  ): Promise<Message[]> {
    return await this.conversationService.getConversationMessage(id, req.user);
  }
}
