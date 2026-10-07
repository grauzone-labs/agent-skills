// Pricing rules for the checkout service. No page or component renders these.
export interface Cart { subtotal: number; items: number; coupon?: string; member: boolean; }

export function discount(cart: Cart): number {
  let rate = 0;
  if (cart.items >= 10) rate += 0.05;
  if (cart.member) rate += 0.1;
  if (cart.coupon === 'SPRING') rate += 0.15;
  return Math.min(rate, 0.25) * cart.subtotal;
}
