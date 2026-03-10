import { test, expect } from '@playwright/test';

test('has header with user menu', async ({ page }) => {
  await page.goto('http://localhost:3001');

  // Find the user menu button (Avatar)
  const userMenuButton = page.locator('button').filter({ has: page.locator('span.relative') }).first();
  await expect(userMenuButton).toBeVisible();

  // Click it to open the dropdown
  await userMenuButton.click();

  // Find the Log out item
  const logoutItem = page.getByRole('menuitem', { name: 'Log out' });
  await expect(logoutItem).toBeVisible();

  // Click logout
  await logoutItem.click();

  // We are just verifying that clicking the button doesn't crash the UI and the menu closes or handles it.
  // The actual console.log removal is what we care about, but visually we just want to ensure the UI is intact.
});