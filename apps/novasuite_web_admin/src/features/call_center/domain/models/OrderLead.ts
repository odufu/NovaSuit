export type QueueStatus = 'new_lead' | 'call_back' | 'confirmed' | 'cancelled' | 'unavailable';

export interface OrderLead {
  id: string;
  orderNumber: string;
  customerName: string;
  customerPhone: string;
  productName: string;
  deliveryState: string;
  deliveryAddress: string;
  totalAmount: number;
  currency: string;
  status: QueueStatus;
  createdAt: string;
  assignedRepExtension?: string;
}

export const MOCK_ORDER_LEADS: OrderLead[] = [
  {
    id: '1',
    orderNumber: 'ORD-2026-8901',
    customerName: 'Chief Bartholomew Okonkwo',
    customerPhone: '+234 803 123 4567',
    productName: 'Grazer Herbal Tea',
    deliveryState: 'Lagos',
    deliveryAddress: '14 Isaac John Street, Ikeja',
    totalAmount: 50000,
    currency: '₦',
    status: 'new_lead',
    createdAt: '2026-07-26T10:00:00Z',
    assignedRepExtension: '101',
  },
  {
    id: '2',
    orderNumber: 'ORD-2026-8902',
    customerName: 'Dr. Folake Adeleke',
    customerPhone: '+234 802 987 6543',
    productName: 'Vitality Booster',
    deliveryState: 'Abuja',
    deliveryAddress: 'Aso Drive Plot 402, Maitama',
    totalAmount: 28000,
    currency: '₦',
    status: 'call_back',
    createdAt: '2026-07-26T10:15:00Z',
    assignedRepExtension: '102',
  },
  {
    id: '3',
    orderNumber: 'ORD-2026-8903',
    customerName: 'Alhaji Ibrahim Danladi',
    customerPhone: '+234 805 444 3322',
    productName: 'Grazer Herbal Tea',
    deliveryState: 'Kano',
    deliveryAddress: '7 Lamidu Road',
    totalAmount: 22000,
    currency: '₦',
    status: 'new_lead',
    createdAt: '2026-07-26T10:30:00Z',
    assignedRepExtension: '103',
  },
  {
    id: '4',
    orderNumber: 'ORD-2026-8904',
    customerName: 'Engineer Chidi Nnamdi',
    customerPhone: '+234 806 777 8899',
    productName: 'Vitality Booster',
    deliveryState: 'Rivers',
    deliveryAddress: '98 Aba Road, Garrison, Port Harcourt',
    totalAmount: 25000,
    currency: '₦',
    status: 'new_lead',
    createdAt: '2026-07-26T10:45:00Z',
    assignedRepExtension: '104',
  },
];
