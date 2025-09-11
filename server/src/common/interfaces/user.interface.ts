export interface OrgUser {
  id: string;
  username: string;
  type: 'org';
}

export interface JwtPayload {
  sub: string;
  username: string;
  type: 'org';
}
