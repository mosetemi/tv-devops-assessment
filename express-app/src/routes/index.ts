import { Router } from 'express';

const router = Router();

router.get('/', (_req, res) => {
  res.send('Hello from Express + TypeScript!');
});

// Health check endpoint to check and return local health status
router.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

export default router;
