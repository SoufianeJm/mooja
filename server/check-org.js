const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function checkOrg() {
  try {
    const org = await prisma.org.findFirst({
      where: { username: 'techforpalestine' },
      select: {
        id: true,
        name: true,
        username: true,
        pictureUrl: true,
        socialMediaPlatform: true,
        socialMediaHandle: true,
        createdAt: true,
        verificationStatus: true
      }
    });
    
    if (org) {
      console.log('Organization found:');
      console.log(JSON.stringify(org, null, 2));
    } else {
      console.log('Organization "techforpalestine" not found');
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkOrg();
