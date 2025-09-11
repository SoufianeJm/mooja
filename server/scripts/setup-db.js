#!/usr/bin/env node

/**
 * Database Setup Script for Mooja
 * Automatically configures the right database based on environment
 */

const fs = require('fs');
const path = require('path');

function updatePrismaSchema(usePostgres = false) {
  const schemaPath = path.join(__dirname, '../prisma/schema.prisma');
  let schema = fs.readFileSync(schemaPath, 'utf8');
  
  if (usePostgres) {
    // Switch to PostgreSQL
    schema = schema.replace(
      /datasource db \{[\s\S]*?\}/,
      `datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}`
    );
    console.log('✅ Schema configured for PostgreSQL');
  } else {
    // Switch to SQLite (development)
    schema = schema.replace(
      /datasource db \{[\s\S]*?\}/,
      `datasource db {
  provider = "sqlite"
  url      = "file:./dev.db"
}`
    );
    console.log('✅ Schema configured for SQLite (development)');
  }
  
  fs.writeFileSync(schemaPath, schema);
}

function createEnvFile() {
  const envPath = path.join(__dirname, '../.env');
  const envExamplePath = path.join(__dirname, '../.env.example');
  
  if (!fs.existsSync(envPath)) {
    fs.copyFileSync(envExamplePath, envPath);
    console.log('✅ Created .env file from .env.example');
  } else {
    console.log('ℹ️  .env file already exists');
  }
}

// Main setup logic
const args = process.argv.slice(2);
const usePostgres = args.includes('--postgres') || process.env.NODE_ENV === 'production';

console.log('🔧 Setting up Mooja database...');
createEnvFile();
updatePrismaSchema(usePostgres);

if (usePostgres) {
  console.log('\n📝 Next steps for PostgreSQL:');
  console.log('1. Update DATABASE_URL in .env with your PostgreSQL connection string');
  console.log('2. Run: npm run prisma:generate');
  console.log('3. Run: npm run prisma:migrate');
} else {
  console.log('\n📝 Next steps for SQLite (development):');
  console.log('1. Run: npm run prisma:generate');
  console.log('2. Run: npm run prisma:migrate');
  console.log('3. Run: npm run prisma:seed');
}

console.log('\n🚀 Database setup complete!');
