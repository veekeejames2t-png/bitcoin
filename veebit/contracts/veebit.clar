;; Veebit Name Registry

;; Data variables
(define-data-var admin (optional principal) none)
(define-data-var fee uint u100000) ;; default fee: 0.1 STX (in microSTX)

;; Mappings
(define-map name->owner { name: (buff 32) } { owner: principal })
(define-map owner->name { owner: principal } { name: (buff 32) })

;; Error codes
(define-constant err-not-initialized u100)
(define-constant err-already-initialized u101)
(define-constant err-unauthorized u401)
(define-constant err-name-taken u201)
(define-constant err-already-registered u202)
(define-constant err-not-found u404)

;; Helpers
(define-read-only (contract-principal)
  (as-contract tx-sender)
)

(define-read-only (is-admin (who principal))
  (match (var-get admin)
    admin-principal (is-eq admin-principal who)
    false))

;; Initialize admin to the first caller; can only be called once
(define-public (initialize)
  (if (is-none (var-get admin))
      (begin
        (var-set admin (some tx-sender))
        (ok true))
      (err err-already-initialized)))

;; Admin-only: set registration fee (in microSTX)
(define-public (set-fee (new-fee uint))
  (if (is-admin tx-sender)
      (begin
        (var-set fee new-fee)
        (ok true))
      (err err-unauthorized)))

;; Read-only views
(define-read-only (get-fee)
  (ok (var-get fee)))

(define-read-only (get-admin)
  (ok (var-get admin)))

(define-read-only (resolve (name (buff 32)))
  (match (map-get? name->owner { name: name })
    entry (ok (some (get owner entry)))
    (ok none)))

(define-read-only (name-of (who principal))
  (match (map-get? owner->name { owner: who })
    entry (ok (some (get name entry)))
    (ok none)))

;; Public: register a unique name by paying the fee
(define-public (register (name (buff 32)))
  (let ((exists? (map-get? name->owner { name: name }))
        (has-name? (map-get? owner->name { owner: tx-sender }))
        (contract (contract-principal)))
    (if (is-none exists?)
        (if (is-none has-name?)
            (match (stx-transfer? (var-get fee) tx-sender contract)
              ok-val
                (begin
                  (map-set name->owner { name: name } { owner: tx-sender })
                  (map-set owner->name { owner: tx-sender } { name: name })
                  (ok true))
              err-val
                (err err-val))
            (err err-already-registered))
        (err err-name-taken))))

;; Admin-only: withdraw STX from the contract to a recipient
(define-public (withdraw (amount uint) (recipient principal))
  (if (is-admin tx-sender)
      (match (stx-transfer? amount (contract-principal) recipient)
        ok-val (ok true)
        err-val (err err-val))
      (err err-unauthorized)))
