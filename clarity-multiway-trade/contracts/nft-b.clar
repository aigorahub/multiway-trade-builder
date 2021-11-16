;; Agent-3  -->  ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
;; Agent-1  -->  ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5
;; Agent-2  -->  ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG

(impl-trait .nft-trait.nft-trait)

;; Non Fungible Token - ERC-721
(define-non-fungible-token ItemB uint)

;; Storage
(define-map tokens-spender
  uint
  principal)
(define-map tokens-count
  principal
  uint)
(define-map accounts-operator
  (tuple (operator principal) (account principal))
  (tuple (is-approved bool)))

;; ERC-721 Internals

;; Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
  (default-to u0 (map-get? tokens-count account)))

;; Gets the approved address for a token ID, or zero if no address set (approved method in ERC721)
(define-private (is-spender-approved (spender principal) (token-id uint))
  (let ((approved-spender
         (unwrap! (map-get? tokens-spender token-id)
                   false))) ;; return false if no specified spender
    (is-eq spender approved-spender)))

;; Tells whether an operator is approved by a given owner (isApprovedForAll method in ERC721)
(define-private (is-operator-approved (account principal) (operator principal))
  (default-to false
    (get is-approved
         (map-get? accounts-operator {operator: operator, account: account}))))

(define-private (is-owner (actor principal) (token-id uint))
  (is-eq actor
       ;; if no owner, return false
       (unwrap! (nft-get-owner? ItemB token-id) false)))

;; Returns whether the given actor can transfer a given token ID.
;; To be optimized
(define-private (can-transfer (actor principal) (token-id uint))
  (or
   (is-owner actor token-id)
   (is-spender-approved actor token-id)
   (is-operator-approved (unwrap! (nft-get-owner? ItemB token-id) false) actor)))

;; Internal - Register token
(define-private (mint (new-owner principal) (token-id uint))
  (let ((current-balance (balance-of new-owner)))
      (match (nft-mint? ItemB token-id new-owner)
        success
          (begin
            (map-set tokens-count
              new-owner
              (+ u1 current-balance))
            (ok success))
        error (nft-mint-err error))))

;; Internal - Tranfer token
(define-private (transfer-token (token-id uint) (owner principal) (new-owner principal))
  (let
    ((current-balance-owner (balance-of owner))
      (current-balance-new-owner (balance-of new-owner)))
    (begin
      (map-delete tokens-spender
        token-id)
      (map-set tokens-count
        owner
        (- current-balance-owner u1))
      (map-set tokens-count
        new-owner
        (+ current-balance-new-owner u1))
      (match (nft-transfer? ItemB token-id owner new-owner)
        success (ok success)
        error (nft-transfer-err error)))))

;; Public functions

;; Approves another address to transfer the given token ID (approve method in ERC721)
;; To be optimized
(define-public (set-spender-approval (spender principal) (token-id uint))
  (if (is-eq spender tx-sender)
      sender-equals-recipient-err
      (if (or (is-owner tx-sender token-id)
              (is-operator-approved
               (unwrap! (nft-get-owner? ItemB token-id) nft-not-found-err)
               tx-sender))
          (begin
            (map-set tokens-spender
                        token-id
                        spender)
            (ok token-id))
          not-approved-spender-err)))

;; Sets or unsets the approval of a given operator (setApprovalForAll method in ERC721)
(define-public (set-operator-approval (operator principal) (is-approved bool))
  (if (is-eq operator tx-sender)
      sender-equals-recipient-err
      (begin
        (map-set accounts-operator
                    {operator: operator, account: tx-sender}
                    {is-approved: is-approved})
        (ok true))))

;; Transfers the ownership of a given token ID to another address.
(define-public (transfer-from (token-id uint) (owner principal) (recipient principal))
  (begin
    (asserts! (can-transfer tx-sender token-id) not-approved-spender-err)
    (asserts! (is-owner owner token-id) nft-not-owned-err)
    (asserts! (not (is-eq recipient owner)) sender-equals-recipient-err)
    (transfer-token token-id owner recipient)))

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (transfer-from token-id tx-sender recipient))

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? ItemB token-id)))

(define-read-only (get-ownerr (entry {nft-id: uint}))
  (ok (nft-get-owner? ItemB (get nft-id entry))))
  ;; (ok (get nft-address entry)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok u1))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "ItemB Contract Owner - Agent1"))
)

;; (define-map assets nft)

(define-public (abcd-efgh)
  (ok (map get-ownerr (list {nft-id: u1})))
)

;; error handling
(define-constant nft-not-owned-err (err u401)) ;; unauthorized
(define-constant not-approved-spender-err (err u403)) ;; forbidden
(define-constant nft-not-found-err (err u404)) ;; not found
(define-constant sender-equals-recipient-err (err u405)) ;; method not allowed
(define-constant nft-exists-err (err u409)) ;; conflict

(define-map err-strings (response uint uint) (string-ascii 32))
(map-insert err-strings nft-not-owned-err "nft-not-owned")
(map-insert err-strings not-approved-spender-err "not-approaved-spender")
(map-insert err-strings nft-not-found-err "nft-not-found")
(map-insert err-strings nft-exists-err "nft-exists")

(define-private (nft-transfer-err (code uint))
  (if (is-eq u1 code)
    nft-not-owned-err
    (if (is-eq u2 code)
      sender-equals-recipient-err
      (if (is-eq u3 code)
        nft-not-found-err
        (err code)))))

(define-private (nft-mint-err (code uint))
  (if (is-eq u1 code)
    nft-exists-err
    (err code)))

(define-read-only (get-errstr (code uint))
  (unwrap! (map-get? err-strings (err code)) "unknown-error"))

;; ;; Minting Some tokens
(begin
  (try! (mint 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u1))
  (try! (mint 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u2))
  (try! (mint 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u3))
  (try! (mint 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u4))
  (try! (mint 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u5))
  (try! (mint 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u6))
  (try! (mint 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u7))
)