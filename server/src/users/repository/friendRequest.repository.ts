import { EntityRepository, Repository } from 'typeorm';
import { FriendRequest } from '../entity/friendRequest.entity';

@EntityRepository(FriendRequest)
export class FriendRequestRepository extends Repository<FriendRequest> {
  public async findById(id: string) {
    return await this.findOne({ id });
  }

  public async getByTargetAndOpenTrue(target: string) {
    return await this.find({ target, open: true });
  }
}
