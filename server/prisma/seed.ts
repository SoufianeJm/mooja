import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

// Import constants to avoid magic numbers
const BCRYPT_ROUNDS = 10; // Standard bcrypt rounds for development
const ONE_DAY_MS = 24 * 60 * 60 * 1000;
const ONE_WEEK_MS = 7 * ONE_DAY_MS;
const TWO_WEEKS_MS = 14 * ONE_DAY_MS;
const THREE_DAYS_MS = 3 * ONE_DAY_MS;
const ONE_MONTH_MS = 30 * ONE_DAY_MS;

const prisma = new PrismaClient();

async function main() {
  // Safety check - prevent accidental production seeding
  if (process.env.NODE_ENV === 'production') {
    console.error('❌ SAFETY: Seed script cannot run in production environment');
    console.error('   Set NODE_ENV to "development" or "test" to seed data');
    process.exit(1);
  }
  
  console.log(`🌱 Seeding database in ${process.env.NODE_ENV || 'development'} mode...`);
  
  // Create a verified test organization
  const hashedPassword = await bcrypt.hash('testpassword123', BCRYPT_ROUNDS);
  
  const testOrg = await prisma.org.upsert({
    where: { username: 'test_org' },
    update: {},
    create: {
      name: 'Test Organization',
      username: 'test_org',
      password: hashedPassword,
      country: 'US',
      socialMediaPlatform: 'Instagram',
      socialMediaHandle: '@test_org',
      verificationStatus: 'verified',
      verifiedAt: new Date(),
    },
  });

  console.log('Created test organization:', testOrg);

  // Create a pending organization for testing verification workflow
  const pendingOrg = await prisma.org.upsert({
    where: { username: 'climate_warriors' },
    update: {},
    create: {
      name: 'Climate Warriors',
      username: 'climate_warriors',
      password: await bcrypt.hash('climatepass123', BCRYPT_ROUNDS),
      country: 'GB',
      socialMediaPlatform: 'Instagram',
      socialMediaHandle: '@climate.warriors.uk',
      verificationStatus: 'pending',
    },
  });

  console.log('Created pending organization:', pendingOrg);

  // Delete old protests to avoid duplicates (development/test only)
  console.log('🗑️  Clearing existing protest data...');
  await prisma.protest.deleteMany({});

  // Create some sample protests with various dates (past, present, future)
  const currentDate = new Date();
  const protests = [
    {
      title: 'March For Gaza',
      dateTime: new Date(currentDate.getTime() + 2 * 60 * 60 * 1000), // 2 hours from now
      country: 'MA',
      city: 'Casablanca',
      location: 'United Nations Square, Casablanca',
      description: 'Stand in solidarity with Palestine',
      organizerId: testOrg.id,
    },
    {
      title: 'Climate Action Now',
      dateTime: new Date(currentDate.getTime() + ONE_DAY_MS), // Tomorrow
      country: 'MA',
      city: 'Rabat',
      location: 'Parliament Building, Rabat',
      description: 'Urgent action needed for climate change',
      organizerId: testOrg.id,
    },
    {
      title: 'United For Palestine',
      dateTime: new Date(currentDate.getTime() + THREE_DAYS_MS), // 3 days from now
      country: 'MA',
      city: 'Casablanca',
      location: 'Bab Al Had Square',
      description: 'Peaceful demonstration for Palestinian rights',
      organizerId: testOrg.id,
    },
    {
      title: 'Education Reform Rally',
      dateTime: new Date(currentDate.getTime() + ONE_WEEK_MS), // 1 week from now
      country: 'MA',
      city: 'Fes',
      location: 'University Campus, Fes',
      description: 'Demanding better education policies',
      organizerId: testOrg.id,
    },
    {
      title: 'Healthcare Workers March',
      dateTime: new Date(currentDate.getTime() + TWO_WEEKS_MS), // 2 weeks from now
      country: 'MA',
      city: 'Casablanca',
      location: 'Ibn Rochd Hospital',
      description: 'Supporting healthcare worker rights',
      organizerId: testOrg.id,
    },
    {
      title: 'Women\'s Rights Assembly',
      dateTime: new Date(currentDate.getTime() + ONE_MONTH_MS), // 1 month from now
      country: 'MA',
      city: 'Marrakech',
      location: 'Jemaa el-Fnaa Square',
      description: 'Equal rights for all women',
      organizerId: testOrg.id,
    }
  ];

  // Create all protests in parallel for better performance
  const createdProtests = await Promise.all(
    protests.map(protestData => 
      prisma.protest.create({ data: protestData })
    )
  );

  console.log(`Created ${createdProtests.length} sample protests:`, createdProtests.map((p: any) => ({ title: p.title, dateTime: p.dateTime })));
  
  // Create some invite codes for testing
  console.log('🎟️  Creating invite codes...');
  
  // Active invite code
  const activeInvite = await prisma.inviteCode.create({
    data: {
      code: 'MOOJA-2024-DEMO',
      isUsed: false,
      expiresAt: new Date(currentDate.getTime() + ONE_WEEK_MS), // Expires in 1 week
      sentTo: '@new_org_demo',
    },
  });
  
  // Expired invite code
  const expiredInvite = await prisma.inviteCode.create({
    data: {
      code: 'MOOJA-2024-EXPIRED',
      isUsed: false,
      expiresAt: new Date(currentDate.getTime() - ONE_DAY_MS), // Expired yesterday
      sentTo: '@expired_org',
    },
  });
  
  // Used invite code
  const usedInvite = await prisma.inviteCode.create({
    data: {
      code: 'MOOJA-2024-USED',
      isUsed: true,
      expiresAt: new Date(currentDate.getTime() + ONE_WEEK_MS),
      sentTo: '@test_org',
      sentAt: new Date(currentDate.getTime() - ONE_DAY_MS),
    },
  });
  
  // Update test_org to have used the invite code
  await prisma.org.update({
    where: { id: testOrg.id },
    data: { inviteCodeUsed: usedInvite.code },
  });
  
  console.log('Created invite codes:', { activeInvite, expiredInvite, usedInvite });
  
  console.log('\n✅ Seed data created successfully!');
  console.log('\n📝 Test credentials:');
  console.log('Username: test_org');
  console.log('Password: testpassword123');
  console.log('\n🎟️  Test invite code:');
  console.log('Code: MOOJA-2024-DEMO (active, not used)');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
