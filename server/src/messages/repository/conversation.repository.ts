import { EntityRepository, Repository } from 'typeorm';
import { Conversation } from '../entity/conversation.entity';

@EntityRepository(Conversation)
export class ConversationRepository extends Repository<Conversation> { }
