import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnTable,
  FlutterShadcnTableHeader,
  FlutterShadcnTableBody,
  FlutterShadcnTableRow,
  FlutterShadcnTableHead,
  FlutterShadcnTableCell,
  FlutterShadcnBadge,
} from '@openwebf/react-shadcn-ui';

export const ShadcnTablePage: React.FC = () => {
  const invoices = [
    { id: 'INV001', status: 'Paid', method: 'Credit Card', amount: '$250.00' },
    { id: 'INV002', status: 'Pending', method: 'PayPal', amount: '$150.00' },
    { id: 'INV003', status: 'Unpaid', method: 'Bank Transfer', amount: '$350.00' },
    { id: 'INV004', status: 'Paid', method: 'Credit Card', amount: '$450.00' },
    { id: 'INV005', status: 'Paid', method: 'PayPal', amount: '$550.00' },
  ];

  const users = [
    { name: 'John Doe', email: 'john@example.com', role: 'Admin', status: 'Active' },
    { name: 'Jane Smith', email: 'jane@example.com', role: 'User', status: 'Active' },
    { name: 'Bob Johnson', email: 'bob@example.com', role: 'User', status: 'Inactive' },
    { name: 'Alice Brown', email: 'alice@example.com', role: 'Editor', status: 'Active' },
  ];

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'Paid':
      case 'Active':
        return <FlutterShadcnBadge>{status}</FlutterShadcnBadge>;
      case 'Pending':
        return <FlutterShadcnBadge variant="secondary">{status}</FlutterShadcnBadge>;
      case 'Unpaid':
      case 'Inactive':
        return <FlutterShadcnBadge variant="destructive">{status}</FlutterShadcnBadge>;
      default:
        return <FlutterShadcnBadge variant="outline">{status}</FlutterShadcnBadge>;
    }
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-3xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Table</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Invoice Table</h2>
            <div className="border rounded-lg overflow-hidden">
              <FlutterShadcnTable>
                <FlutterShadcnTableHeader>
                  <FlutterShadcnTableRow>
                    <FlutterShadcnTableHead>Invoice</FlutterShadcnTableHead>
                    <FlutterShadcnTableHead>Status</FlutterShadcnTableHead>
                    <FlutterShadcnTableHead>Method</FlutterShadcnTableHead>
                    <FlutterShadcnTableHead>Amount</FlutterShadcnTableHead>
                  </FlutterShadcnTableRow>
                </FlutterShadcnTableHeader>
                <FlutterShadcnTableBody>
                  {invoices.map((invoice) => (
                    <FlutterShadcnTableRow key={invoice.id}>
                      <FlutterShadcnTableCell>{invoice.id}</FlutterShadcnTableCell>
                      <FlutterShadcnTableCell>{getStatusBadge(invoice.status)}</FlutterShadcnTableCell>
                      <FlutterShadcnTableCell>{invoice.method}</FlutterShadcnTableCell>
                      <FlutterShadcnTableCell>{invoice.amount}</FlutterShadcnTableCell>
                    </FlutterShadcnTableRow>
                  ))}
                </FlutterShadcnTableBody>
              </FlutterShadcnTable>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">User Table</h2>
            <div className="border rounded-lg overflow-hidden">
              <FlutterShadcnTable>
                <FlutterShadcnTableHeader>
                  <FlutterShadcnTableRow>
                    <FlutterShadcnTableHead>Name</FlutterShadcnTableHead>
                    <FlutterShadcnTableHead>Email</FlutterShadcnTableHead>
                    <FlutterShadcnTableHead>Role</FlutterShadcnTableHead>
                    <FlutterShadcnTableHead>Status</FlutterShadcnTableHead>
                  </FlutterShadcnTableRow>
                </FlutterShadcnTableHeader>
                <FlutterShadcnTableBody>
                  {users.map((user, index) => (
                    <FlutterShadcnTableRow key={index}>
                      <FlutterShadcnTableCell>
                        <div className="font-medium">{user.name}</div>
                      </FlutterShadcnTableCell>
                      <FlutterShadcnTableCell>
                        <span className="text-gray-500">{user.email}</span>
                      </FlutterShadcnTableCell>
                      <FlutterShadcnTableCell>
                        <FlutterShadcnBadge variant="outline">{user.role}</FlutterShadcnBadge>
                      </FlutterShadcnTableCell>
                      <FlutterShadcnTableCell>{getStatusBadge(user.status)}</FlutterShadcnTableCell>
                    </FlutterShadcnTableRow>
                  ))}
                </FlutterShadcnTableBody>
              </FlutterShadcnTable>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
