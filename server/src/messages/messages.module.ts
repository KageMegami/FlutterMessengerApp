import { forwardRef, Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModule } from 'src/users/users.module';
import { ConversationsController } from './controller/conversations.controller';
import { MessagesController } from './controller/messages.controller';
import { ConversationRepository } from './repository/conversation.repository';
import { MessageRepository } from './repository/message.repository';
import { ConversationsService } from './service/conversations.service';
import { MessagesService } from './service/messages.service';

@Module({
  imports: [
    forwardRef(() => UsersModule),
    TypeOrmModule.forFeature([MessageRepository]),
    TypeOrmModule.forFeature([ConversationRepository]),
  ],
  controllers: [MessagesController, ConversationsController],
  providers: [MessagesService, ConversationsService],
  exports: [ConversationsService],
})
export class MessagesModule { }
