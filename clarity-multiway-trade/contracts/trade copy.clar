;; ;; Agent-3  -->  ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
;; ;; Agent-1  -->  ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5
;; ;; Agent-2  -->  ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
;; (use-trait nft .nft-trait.nft-trait)

;; ;; Agents
;; (define-constant agent-two 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
;; (define-constant agent-three 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
;; (define-constant agent-one 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)

;; ;; Signature of Agents
;; (define-data-var agent-one-status bool false)
;; (define-data-var agent-two-status bool false)
;; (define-data-var agent-three-status bool false)

;; ;; Agents trading tokenId s
;; (define-data-var agent-one-tokenID uint u0)
;; (define-data-var agent-two-tokenID uint u0)
;; (define-data-var agent-three-tokenID uint u0)

;; (define-data-var flag bool false)


;; ;; Errors
;; (define-constant deal-closed (err u400))


;; (define-map assets
;;     {nft-address: (optional principal), nft-id: uint}
;;     {status: }
;; )

;; ;; Internal Functions

;; (define-private (check-deal)
;;   (if (and (var-get agent-one-status) (var-get agent-two-status) (var-get agent-three-status) true)
;;     (ok true)
;;     (ok false)
;;   )
;; )

;; (define-private (check-deal-status)
;;   (unwrap-panic
;;     (if (and (var-get agent-one-status) (var-get agent-two-status) (var-get agent-three-status))
;;       deal-closed
;;       (ok true)
;;     )
;;   )
;; )

;; ;; Check for DEAL made! 
;; ;; If All agents accepted So, automatically perform exchanges!!
;; (define-private (run-exchange)
;;   (begin
;;     (unwrap-panic
;;       (as-contract (contract-call? .nft-c transfer (var-get agent-two-tokenID) tx-sender agent-one))
;;     )
;;     (unwrap-panic
;;       (begin
;;         (unwrap-panic
;;           (as-contract (contract-call? .nft-b transfer (var-get agent-three-tokenID) tx-sender agent-two))
;;         )
;;         (as-contract (stx-transfer? u500 tx-sender agent-two))
;;       )
;;     )
;;     (unwrap-panic
;;       (as-contract (contract-call? .nft-a transfer (var-get agent-one-tokenID) tx-sender agent-three))
;;     )
;;     (ok true)
;;   )  
;; )

;; ;; Returning their NFT tokenID back to agents [i.e it's Owners]
;; (define-private (close-the-deal)
;;   (begin 
;;     (if (is-eq (var-get agent-one-status) true)
;;       (begin
;;         (unwrap-panic
;;           (begin
;;             (unwrap-panic
;;               (as-contract (contract-call? .nft-a transfer (var-get agent-one-tokenID) tx-sender agent-one))
;;             )
;;             (as-contract (stx-transfer? u500 tx-sender agent-one))
;;           )
;;         )
;;         (var-set agent-one-status false)
;;         (var-set agent-one-tokenID u0)
;;       )
;;       true
;;     )
;;     (if (is-eq (var-get agent-three-status) true)
;;       (begin
;;         (unwrap-panic
;;           (as-contract (contract-call? .nft-b transfer (var-get agent-three-tokenID) tx-sender agent-three))
;;         )
;;         (var-set agent-three-status false)
;;         (var-set agent-three-tokenID u0)
;;       )
;;       true
;;     )
;;     (if (is-eq (var-get agent-two-status) true)
;;       (begin
;;         (unwrap-panic
;;           (as-contract (contract-call? .nft-c transfer (var-get agent-two-tokenID) tx-sender agent-two))
;;         )
;;         (var-set agent-two-status false)
;;         (var-set agent-two-tokenID u0)
;;       )
;;       true
;;     )
;;     (ok true)
;;   ) 
;; )

;; ;; External Functions

;; ;; Deposite for trading!
;; (define-public (trade (nft-address <nft>) (tokenID uint) (stx-amount uint))
;;   (begin 
;;     (unwrap-panic
;;       (begin
;;         (if (is-eq tx-sender agent-one)
;;           (begin
;;             (var-set agent-one-status true)
;;             (var-set agent-one-tokenID tokenID)
;;             (var-set flag true)
;;           )
;;           true
;;         )
;;         (if (is-eq tx-sender agent-two)
;;           (begin
;;             (var-set agent-two-status true)
;;             (var-set agent-two-tokenID tokenID)
;;             (var-set flag true)
;;           )
;;           true
;;         )
;;         (if (is-eq tx-sender agent-three)
;;           (begin
;;             (var-set agent-three-status true)
;;             (var-set agent-three-tokenID tokenID)
;;             (var-set flag true)
;;           )
;;           true
;;         )

;;         (if (is-eq (var-get flag) true)
;;           (ok (var-set flag false))
;;           (ok false)
;;         )
;;       )
;;     )
;;     (unwrap-panic
;;       (begin
;;         (unwrap-panic
;;           (contract-call? nft-address transfer tokenID tx-sender (as-contract tx-sender))
;;         )
;;         (if (is-eq stx-amount u0)
;;           (ok true)
;;           (stx-transfer? stx-amount tx-sender (as-contract tx-sender))
;;         )
;;       )
;;     )
    

;;     (if (and (var-get agent-one-status) (var-get agent-two-status) (var-get agent-three-status) true)  
;;       (begin
;;         (unwrap-panic
;;           (run-exchange)
;;         )
;;         ;; re-setting status to false
;;         (var-set agent-one-status false)
;;         (var-set agent-two-status false)
;;         (var-set agent-three-status false)

;;         ;; re-setting tokenID's to u0
;;         (var-set agent-one-tokenID u0)
;;         (var-set agent-two-tokenID u0)
;;         (var-set agent-three-tokenID u0)
;;       )  
;;       true
;;     )
;;     (ok true)
;;   )
;; )

;; ;; Deposite for trading!
;; (define-public (deposite )
;;   (begin 
;;     (unwrap-panic
;;       (begin
;;         (if (is-eq tx-sender agent-one)
;;           (begin
;;             (var-set agent-one-status true)
;;             (var-set agent-one-tokenID tokenID)
;;             (var-set flag true)
;;           )
;;           true
;;         )
;;         (if (is-eq tx-sender agent-two)
;;           (begin
;;             (var-set agent-two-status true)
;;             (var-set agent-two-tokenID tokenID)
;;             (var-set flag true)
;;           )
;;           true
;;         )
;;         (if (is-eq tx-sender agent-three)
;;           (begin
;;             (var-set agent-three-status true)
;;             (var-set agent-three-tokenID tokenID)
;;             (var-set flag true)
;;           )
;;           true
;;         )

;;         (if (is-eq (var-get flag) true)
;;           (ok (var-set flag false))
;;           (ok false)
;;         )
;;       )
;;     )
;;     (unwrap-panic
;;       (begin
;;         (unwrap-panic
;;           (contract-call? nft-address transfer tokenID tx-sender (as-contract tx-sender))
;;         )
;;         (if (is-eq stx-amount u0)
;;           (ok true)
;;           (stx-transfer? stx-amount tx-sender (as-contract tx-sender))
;;         )
;;       )
;;     )
    

;;     (if (and (var-get agent-one-status) (var-get agent-two-status) (var-get agent-three-status) true)  
;;       (begin
;;         (unwrap-panic
;;           (run-exchange)
;;         )
;;         ;; re-setting status to false
;;         (var-set agent-one-status false)
;;         (var-set agent-two-status false)
;;         (var-set agent-three-status false)

;;         ;; re-setting tokenID's to u0
;;         (var-set agent-one-tokenID u0)
;;         (var-set agent-two-tokenID u0)
;;         (var-set agent-three-tokenID u0)
;;       )  
;;       true
;;     )
;;     (ok true)
;;   )
;; )

;; ;; Cancel the trading/exchange!!
;; (define-public (cancel)
;;   (begin
;;     (check-deal-status)
;;     (if (or (is-eq tx-sender agent-one) (is-eq tx-sender agent-two) (is-eq tx-sender agent-three))
;;       (begin 
;;         (unwrap-panic
;;           (close-the-deal)
;;         )
;;         (ok true)
;;       )
;;       (ok false)
;;     )
;;   )
;; )

;; ;; STX - Balance!
;; (define-public (stx-balance (address principal))
;;   (ok (stx-get-balance address)) 
;; )

;; ;; (define-public (is-even (numbers (list uint 5)))
;; ;;   (map-each n numbers (is-eq (mod n u2) u0))
;; ;; )

;; (define-read-only (is-even (numbers (list uint 5)))
;;   ;; list comprehension mapping a sequence of numbers to booleans
;;   (for ((n numbers))
;;     (is-eq (mod n u2) u0)))