import { User } from 'src/users/entity/user.entity';
import {
  PrimaryGeneratedColumn,
  Column,
  Entity,
  OneToMany,
  ManyToMany,
  JoinTable,
} from 'typeorm';
import { Message } from './message.entity';

@Entity({ name: 'conversation' })
export class Conversation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @OneToMany(() => Message, (message) => message.conversation)
  messages: Message[];

  @ManyToMany(() => User, (user) => user.conversations)
  @JoinTable()
  users: User[];

  @Column({ type: 'varchar', length: 30 })
  name: string;

  @Column({ type: 'boolean', nullable: true })
  isGroup: boolean;

  @Column({ type: 'varchar', length: 200, nullable: true })
  url_picture: string;
}
