import { createPublicKey, verify } from 'node:crypto';
import { readFileSync } from 'node:fs';

try {
  const [file, publicKey, signature] = process.argv.slice(2);
  const rawKey = Buffer.from(publicKey ?? '', 'base64');
  const rawSignature = Buffer.from(signature ?? '', 'base64');
  if (!file || rawKey.length !== 32 || rawSignature.length !== 64) throw new Error('Invalid verification inputs');
  const key = createPublicKey({
    key: Buffer.concat([Buffer.from('302a300506032b6570032100', 'hex'), rawKey]),
    format: 'der', type: 'spki',
  });
  if (!verify(null, readFileSync(file), key, rawSignature)) throw new Error('Payload does not match the app public key');
} catch (error) {
  process.stderr.write(`${error.message}\n`);
  process.exitCode = 1;
}
