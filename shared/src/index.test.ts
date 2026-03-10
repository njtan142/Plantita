import { test } from 'node:test';
import assert from 'node:assert';
import { generateId } from './index.ts';

test('generateId returns a valid UUID v4', () => {
  const id = generateId();
  // UUID v4 regex
  const uuidRegex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  assert.match(id, uuidRegex);
});

test('generateId returns unique IDs', () => {
  const id1 = generateId();
  const id2 = generateId();
  assert.notStrictEqual(id1, id2);
});
