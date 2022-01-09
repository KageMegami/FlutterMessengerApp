import { PrimaryGeneratedColumn, Column, Entity } from 'typeorm';

@Entity({ name: 'friendRequest' })
export class FriendRequest {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  sender: string;

  @Column({ type: 'uuid' })
  target: string;

  @Column({ type: 'boolean' })
  open: boolean;
}
