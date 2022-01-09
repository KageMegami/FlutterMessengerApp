import { Conversation } from 'src/messages/entity/conversation.entity';
import {
  PrimaryGeneratedColumn,
  Column,
  Entity,
  ManyToMany,
  JoinTable,
} from 'typeorm';

@Entity({ name: 'user' })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 50 })
  id_auth: string;

  @Column({ type: 'varchar', length: 30 })
  firstName: string;

  @Column({ type: 'varchar', length: 30 })
  lastName: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  url_picture: string;

  @ManyToMany(() => Conversation, (conversation) => conversation.users)
  conversations: Conversation[];

  @ManyToMany(() => User)
  @JoinTable()
  friends: User[];

  @Column({ type: 'varchar', length: 500, nullable: true })
  FCM_token: string;
}
