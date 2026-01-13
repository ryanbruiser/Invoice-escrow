Invoice-Escrow Smart Contract

Overview

**Invoice-Escrow** is a trustless smart contract built on the **Stacks blockchain** that enables secure, invoice-based payment settlements between a payer and a service provider. Funds are locked in escrow and only released when invoice conditions are met, ensuring transparency, accountability, and protection for both parties.

This contract is designed for freelancers, service providers, businesses, and platforms that require verifiable and dispute-resistant invoice payments.

---

Key Features

- On-chain invoice creation and tracking
- Escrowed STX payments tied to invoices
- Controlled fund release upon invoice approval
- Refund mechanism for canceled or rejected invoices
- Read-only functions for invoice verification
- Role-based access control for all sensitive actions

---

Use Cases

- Freelance and contractor payments
- Service-based business invoicing
- DAO or protocol expense settlements
- Trust-minimized B2B transactions
- Transparent payment workflows on-chain

---

Contract Architecture

Invoice Lifecycle

1. **Invoice Creation**
   - Payee creates an invoice specifying payer, amount, and metadata

2. **Funding**
   - Payer deposits STX into escrow for the invoice

3. **Approval & Release**
   - Payer approves the invoice
   - Funds are released to the payee

4. **Cancellation / Refund**
   - Invoice can be canceled based on contract rules
   - Escrowed funds are refunded when applicable

---

Core Functions

Public Functions
- `create-invoice` – Creates a new invoice record
- `fund-invoice` – Deposits STX into escrow
- `approve-invoice` – Releases escrowed funds to the payee
- `cancel-invoice` – Cancels an invoice and refunds funds when valid

Read-Only Functions
- `get-invoice` – Returns invoice details
- `get-invoice-status` – Returns current invoice state
- `is-invoice-funded` – Checks escrow funding status

---

Security Design

- Only authorized parties can approve or cancel invoices
- Funds cannot be withdrawn outside defined state transitions
- Immutable invoice records after creation
- Defensive checks against invalid IDs and unauthorized calls

---

Development & Testing

Requirements
- Stacks blockchain
- Clarinet CLI

Build & Test
```bash
clarinet check
clarinet test
