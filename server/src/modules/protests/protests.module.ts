import { Module } from '@nestjs/common';
import { ProtestsController } from './protests.controller';
import { ProtestsService } from './protests.service';

@Module({
  imports: [],
  controllers: [ProtestsController],
  providers: [ProtestsService],
  exports: [ProtestsService],
})
export class ProtestsModule {}
