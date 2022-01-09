import { Body, Controller, Post, Request, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from 'src/auth/firebase-auth.guard';
import { Message } from '../entity/message.entity';
import { SendMessageRequestDto } from '../model/message/SendMessageRequest.dto';
import { MessagesService } from '../service/messages.service';

@Controller('messages')
export class MessagesController {
  constructor(private readonly messageService: MessagesService) { }

  @Post()
  @UseGuards(FirebaseAuthGuard)
  public async sendMessage(
    @Request() req,
    @Body() sendMessageRequestDto: SendMessageRequestDto,
  ): Promise<Message> {
    return await this.messageService.addMessage(
      sendMessageRequestDto,
      req.user,
    );
  }
}
