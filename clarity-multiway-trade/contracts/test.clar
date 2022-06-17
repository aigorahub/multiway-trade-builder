(use-trait nft-trait .nft-trait.nft-trait)

(define-private (as-trait (addr <nft-trait>))
  addr
)

;; #[allow(unchecked_data)]
(define-public (transfer
  (nft <nft-trait>)
  (token-id uint)
  (sender principal)
  (recipient principal))

  (contract-call? nft transfer token-id sender recipient)
)

(define-private (transfer_
  (ctx {
    nft: principal,
    token-id: uint,
    sender: principal,
    recipient: principal
  })
  (out (response bool uint)))

  (match out out_
    (transfer
      (try! (match (index-of CONTRACTS (get nft ctx)) idx
        (ok (unwrap! (element-at TRAITS idx) (err u20)))
        (err u10)
      ))
      (get token-id ctx)
      (get sender ctx)
      (get recipient ctx)
    )
    err_ out
  )
)

;; #[allow(unchecked_data)]
(define-public (send-many
  (cfg (list 200 {
    nft: principal,
    token-id: uint,
    sender: principal,
    recipient: principal
  })))

  (fold transfer_ cfg (ok true))
)

(define-private (contract-of_ (nft <nft-trait>))
  (contract-of nft)
)

(define-constant CONTRACTS
  (map contract-of_ TRAITS)
)

(define-constant TRAITS (list
  (as-trait .nft-a) (as-trait .nft-b) (as-trait .nft-c)
))