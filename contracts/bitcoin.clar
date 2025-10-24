(impl-trait .sip10-trait.sip10-ft-trait)

;; Errors
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)

;; Token metadata
(define-constant DECIMALS u8)

;; Storage
(define-data-var owner principal tx-sender)
(define-data-var total-supply uint u0)
(define-map balances { owner: principal } { balance: uint })

;; Internal helpers
(define-private (get-balance-internal (who principal))
  (default-to u0 (get balance (map-get? balances { owner: who })))
)

(define-private (set-balance (who principal) (new-balance uint))
  (if (is-eq new-balance u0)
      (begin (map-delete balances { owner: who }) true)
      (begin (map-set balances { owner: who } { balance: new-balance }) true))
)

;; SIP-010 functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
      (let ((sender-bal (get-balance-internal sender)))
        (if (>= sender-bal amount)
            (begin
              (set-balance sender (- sender-bal amount))
              (set-balance recipient (+ (get-balance-internal recipient) amount))
              (ok true)
            )
            (err ERR-INSUFFICIENT-BALANCE)
        )
      )
      (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-name) (ok "Bitcoin"))
(define-read-only (get-symbol) (ok "BTC"))
(define-read-only (get-decimals) (ok DECIMALS))
(define-read-only (get-balance (who principal)) (ok (get-balance-internal who)))
(define-read-only (get-total-supply) (ok (var-get total-supply)))
(define-read-only (get-token-uri) (ok (some u"https://example.com/bitcoin.json")))

;; Admin
(define-public (mint (recipient principal) (amount uint))
  (if (is-eq tx-sender (var-get owner))
      (let ((recipient-bal (get-balance-internal recipient)))
        (set-balance recipient (+ recipient-bal amount))
        (var-set total-supply (+ (var-get total-supply) amount))
        (ok true)
      )
      (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-owner (new-owner principal))
  (if (is-eq tx-sender (var-get owner))
      (begin
        (var-set owner new-owner)
        (ok true)
      )
      (err ERR-NOT-AUTHORIZED)
  )
)
