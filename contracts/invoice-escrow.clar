;; =====================================================
;; InvoiceEscrow
;; Trust-minimized on-chain invoice settlement
;; =====================================================

;; -----------------------------
;; Data Variables
;; -----------------------------

(define-data-var invoice-counter uint u0)

;; -----------------------------
;; Data Maps
;; -----------------------------

(define-map invoices
  uint
  {
    provider: principal,
    client: principal,
    amount: uint,
    due-block: uint,
    paid: bool,
    settled: bool,
    canceled: bool
  }
)

;; -----------------------------
;; Errors
;; -----------------------------

(define-constant ERR-NOT-FOUND u100)
(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-ALREADY-PAID u102)
(define-constant ERR-NOT-PAID u103)
(define-constant ERR-NOT-DUE u104)
(define-constant ERR-CANCELED u105)

;; -----------------------------
;; Create Invoice
;; -----------------------------

(define-public (create-invoice
  (client principal)
  (amount uint)
  (due-block uint)
)
  (begin
    (asserts! (> amount u0) (err ERR-ALREADY-PAID))
    (asserts! (> due-block stacks-block-height) (err ERR-NOT-DUE))

    (let ((id (+ (var-get invoice-counter) u1)))
      (var-set invoice-counter id)

      (map-set invoices id {
        provider: tx-sender,
        client: client,
        amount: amount,
        due-block: due-block,
        paid: false,
        settled: false,
        canceled: false
      })

      (ok id)
    )
  )
)

;; -----------------------------
;; Fund Invoice
;; -----------------------------

(define-public (pay-invoice (invoice-id uint))
  (let ((invoice (map-get? invoices invoice-id)))
    (match invoice inv
      (begin
        (asserts! (is-eq tx-sender (get client inv)) (err ERR-NOT-AUTHORIZED))
        (asserts! (not (get canceled inv)) (err ERR-CANCELED))
        (asserts! (not (get paid inv)) (err ERR-ALREADY-PAID))

        (map-set invoices invoice-id (merge inv { paid: true }))
        (stx-transfer? (get amount inv) tx-sender (as-contract tx-sender))
      )
      (err ERR-NOT-FOUND)
    )
  )
)

;; -----------------------------
;; Approve & Settle
;; -----------------------------

(define-public (approve-invoice (invoice-id uint))
  (let ((invoice (map-get? invoices invoice-id)))
    (match invoice inv
      (begin
        (asserts! (is-eq tx-sender (get client inv)) (err ERR-NOT-AUTHORIZED))
        (asserts! (get paid inv) (err ERR-NOT-PAID))
        (asserts! (not (get settled inv)) (err ERR-ALREADY-PAID))

        (map-set invoices invoice-id (merge inv { settled: true }))
        (stx-transfer?
          (get amount inv)
          (as-contract tx-sender)
          (get provider inv)
        )
      )
      (err ERR-NOT-FOUND)
    )
  )
)

;; -----------------------------
;; Auto-Settle After Timeout
;; -----------------------------

(define-public (auto-settle (invoice-id uint))
  (let ((invoice (map-get? invoices invoice-id)))
    (match invoice inv
      (begin
        (asserts! (get paid inv) (err ERR-NOT-PAID))
        (asserts! (not (get settled inv)) (err ERR-ALREADY-PAID))
        (asserts! (> stacks-block-height (get due-block inv)) (err ERR-NOT-DUE))

        (map-set invoices invoice-id (merge inv { settled: true }))
        (stx-transfer?
          (get amount inv)
          (as-contract tx-sender)
          (get provider inv)
        )
      )
      (err ERR-NOT-FOUND)
    )
  )
)

;; -----------------------------
;; Cancel Invoice
;; -----------------------------

(define-public (cancel-invoice (invoice-id uint))
  (let ((invoice (map-get? invoices invoice-id)))
    (match invoice inv
      (begin
        (asserts! (is-eq tx-sender (get provider inv)) (err ERR-NOT-AUTHORIZED))
        (asserts! (not (get paid inv)) (err ERR-ALREADY-PAID))

        (map-set invoices invoice-id (merge inv { canceled: true }))
        (ok true)
      )
      (err ERR-NOT-FOUND)
    )
  )
)

;; -----------------------------
;; Read-only Views
;; -----------------------------

(define-read-only (get-invoice (invoice-id uint))
  (map-get? invoices invoice-id)
)
