import { EntityRepository, Repository } from 'typeorm';
import { User } from '../entity/user.entity';

@EntityRepository(User)
export class UserRepository extends Repository<User> {
  public async findByIdAuth(idAuth: string) {
    return await this.findOne({ id_auth: idAuth });
  }

  public async findById(id: string) {
    return await this.findOne({ id });
  }
}
