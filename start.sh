#!/bin/bash
cd server
npm install
npx prisma generate
npm run start:prod
