import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().email('Deve ser um email válido no formato usuario@dominio.com').max(255),
  password: z.string().min(1, 'Senha é obrigatória'),
  rememberLogin: z.boolean().optional().default(false),
});

export type LoginBody = z.infer<typeof loginSchema>;

export interface UserForLogin {
  idUserAccount: number;
  passwordHash: string;
  isLocked: boolean;
  lockedUntil: Date | null;
}

export interface LoginResult {
  token: string;
  user: {
    id: number;
    name: string;
    email: string;
  };
}
