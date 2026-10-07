// Order lifecycle used by the fulfilment service. The question: does cancel after ship behave?
export type OrderState = 'draft' | 'placed' | 'shipped' | 'delivered' | 'cancelled';
export type OrderAction = 'place' | 'ship' | 'deliver' | 'cancel';

export function order(state: OrderState, action: OrderAction): OrderState {
  if (action === 'place' && state === 'draft') return 'placed';
  if (action === 'ship' && state === 'placed') return 'shipped';
  if (action === 'deliver' && state === 'shipped') return 'delivered';
  if (action === 'cancel' && state !== 'delivered') return 'cancelled';
  return state;
}
