import { StripeGateway } from "./stripe";
import { OrderRepo } from "./order-repo";

export class OrderService {
  private repo = new OrderRepo();
  private gateway = new StripeGateway(process.env.STRIPE_KEY!);

  findOrder(id: string) {
    return this.repo.find(id);
  }
  setOrderStatus(id: string, status: string) {
    return this.repo.update(id, { status });
  }
  getOrderTotal(id: string) {
    return this.repo.find(id).then((o) => o.total);
  }
  chargeOrder(id: string, amount: number) {
    return this.gateway.charge(amount, { orderId: id });
  }
  markOrderPaid(id: string, paymentId: string) {
    return this.repo.update(id, { status: "paid", paymentId });
  }
  sendReceipt(id: string, email: string) {
    return this.gateway.sendReceipt(email, { orderId: id });
  }
}

// Every caller repeats the same sequence: findOrder, getOrderTotal,
// chargeOrder, markOrderPaid, sendReceipt.
