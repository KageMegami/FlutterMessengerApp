import { forwardRef, Module } from '@nestjs/common';
import { UsersController } from './controller/users.controller';
import { UsersService } from './service/users.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserRepository } from './repository/user.repository';
import { FriendRequestRepository } from './repository/friendRequest.repository';
import { MessagesModule } from 'src/messages/messages.module';

@Module({
  imports: [
    forwardRef(() => MessagesModule),
    TypeOrmModule.forFeature([UserRepository]),
    TypeOrmModule.forFeature([FriendRequestRepository]),
  ],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],

})
export class UsersModule { }
