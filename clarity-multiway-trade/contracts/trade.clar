(use-trait nft .nft-trait.nft-trait)

(define-constant agent-1 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
(define-constant agent-2 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
(define-constant agent-3 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool false)

(define-data-var flag bool false)


(define-data-var deal bool false)


(define-constant deal-closed (err u300))
(define-constant cannot-escrow-nft (err u301))
(define-constant cannot-escrow-stx (err u302))
(define-constant sender-already-confirmed (err u303))
(define-constant non-tradable-agent (err u304))
(define-constant release-escrow-failed (err u305))


;; u501 - Progress ; u502 - Cancelled ; u503 - Finished
(define-data-var contract-status uint u501)


(define-read-only (check-contract-status)
  (ok (var-get contract-status))
)

(define-private (check-deal)
  (if (and (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) true)
    (ok true)
    (ok false)
  )
)

(define-private (check-deal-status)
  (unwrap-panic
    (if (and (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status))
      deal-closed
      (ok true)
    )
  )
)

(define-private (release-escrow)
  (begin
    (unwrap-panic
      (as-contract (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-b transfer u1 tx-sender agent-1))
    )
    (unwrap-panic
      (begin
        (as-contract (stx-transfer? u500 tx-sender agent-2))
      )
    )
    (unwrap-panic
      (as-contract (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-a transfer u1 tx-sender agent-3))
    )
    (var-set deal true)
    (var-set contract-status u503)
    (ok true)
  )
)

(define-private (close-the-deal)
  (begin
    (if (is-eq (var-get agent-1-status) true)
      (begin
        (unwrap-panic
          (begin
            (unwrap-panic
              (as-contract (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-c transfer u1 tx-sender agent-1))
            )
            (as-contract (stx-transfer? u500 tx-sender agent-1))
          )
        )
        (var-set agent-1-status false)
      )
      true
    )
    (if (is-eq (var-get agent-2-status) true)
      (begin
        (unwrap-panic
          (as-contract (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-c transfer u1 tx-sender agent-2))
        )
        (unwrap-panic
          (as-contract (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-c transfer u2 tx-sender agent-2))
        )
        (var-set agent-2-status false)
      )
      true
    )
    (if (is-eq (var-get agent-3-status) true)
      (begin
        (unwrap-panic
          (as-contract (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-b transfer u1 tx-sender agent-3))
        )
        (var-set agent-3-status false)
      )
      true
    )
    (var-set contract-status u502)
    (ok true)
  )
)

(define-public (confirm-and-escrow)
  (begin
    (var-set flag false)
    (unwrap-panic
      (begin
        (if (is-eq tx-sender agent-1)
          (begin
            (asserts! (is-eq (var-get agent-1-status) false) sender-already-confirmed)
            (asserts!
              (is-ok (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-c transfer u1 tx-sender (as-contract tx-sender)))
              cannot-escrow-nft
            )

            (asserts!
              (is-ok (stx-transfer? u500 tx-sender (as-contract tx-sender)))
              cannot-escrow-stx
            )

            (var-set agent-1-status true)
            (var-set flag true)
          )
          true
        )
        (if (is-eq tx-sender agent-2)
          (begin
            (asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
            (asserts!
              (is-ok (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-c transfer u1 tx-sender (as-contract tx-sender)))
              cannot-escrow-nft
            )
            (asserts!
              (is-ok (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-c transfer u2 tx-sender (as-contract tx-sender)))
              cannot-escrow-nft
            )
            (var-set agent-2-status true)
            (var-set flag true)
          )
          true
        )
        (if (is-eq tx-sender agent-3)
          (begin
            (asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
            (asserts!
              (is-ok (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-b transfer u1 tx-sender (as-contract tx-sender)))
              cannot-escrow-nft
            )
            (var-set agent-3-status true)
            (var-set flag true)
          )
          true
        )

        (ok true)
      )
    )
    (if (and (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) true)
      (begin
        (unwrap-panic
          (release-escrow)
        )
      )
      true
    )
    (if (is-eq (var-get flag) true)
      (ok true)
      non-tradable-agent
    )
  )
)

(define-public (cancel-escrow)
  (begin
    (check-deal-status)
    (if (or (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3))
      (begin
        (unwrap-panic
          (close-the-deal)
        )
        (ok true)
      )
      (ok false)
    )
  )
)

