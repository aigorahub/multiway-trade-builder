import json
from collections import defaultdict


def build_multiway_trade(data):
	##### here is where the data input gets used
	contract_details = data

	CODE = ""
	trait = "(use-trait nft .nft-trait.nft-trait)\n\n"

	agent_sign_false = "(define-data-var agent-%d-status bool false)\n"
	agent_sign_true = "(define-data-var agent-%d-status bool true)\n"
	agent_address = "(define-constant agent-%d '%s)\n"

	flag = "(define-data-var flag bool false)\n\n"
	error = "(define-constant deal-closed (err u400))\n\n"

	param_get = " (var-get agent-%d-status)"
	param_is_eq = " (is-eq tx-sender agent-%d)"

	check_deal = "(define-private (check-deal)\n\t(if (and%s true)\n\t\t(ok true)\n\t\t(ok false)\n\t)\n)\n\n"

	check_deal_status = "(define-private (check-deal-status)\n\t(unwrap-panic\n\t\t(if (and%s)\n\t\t\tdeal-closed\n\t\t\t(ok true)\n\t\t)\n\t)\n)\n\n"

	run_exchange = "(define-private (run-exchange)\n\t(begin\n%s\t\t(ok true)\n\t)\n)\n\n"
	run_exchange_cond_stx = "\t\t(unwrap-panic\n\t\t\t(begin\n%s\t\t\t\t(as-contract (stx-transfer? u%d tx-sender agent-%d))\n\t\t\t)\n\t\t)\n"
	run_exchange_cond = "\t\t(unwrap-panic\n\t\t\t(as-contract (contract-call? '%s transfer u%d tx-sender agent-%d))\n\t\t)\n"
	run_exchange_each_NFT_stx = "\t\t\t\t(unwrap-panic\n\t\t\t\t\t(as-contract (contract-call? '%s transfer u%d tx-sender agent-%d))\n\t\t\t\t)\n"

	close_the_deal = "(define-private (close-the-deal)\n\t(begin\n%s\t\t(ok true)\n\t)\n)\n\n"
	close_the_deal_cond_stx ="\t\t(if (is-eq (var-get agent-%d-status) true)\n\t\t\t(begin\n\t\t\t\t(unwrap-panic\n\t\t\t\t\t(begin\n%s\t\t\t\t\t\t(as-contract (stx-transfer? u%d tx-sender agent-%d))\n\t\t\t\t\t)\n\t\t\t\t)\n\t\t\t\t(var-set agent-%d-status false)\n\t\t\t)\n\t\t\ttrue\n\t\t)\n"
	close_the_deal_cond ="\t\t(if (is-eq (var-get agent-%d-status) true)\n\t\t\t(begin\n%s\t\t\t\t(var-set agent-%d-status false)\n\t\t\t)\n\t\t\ttrue\n\t\t)\n"
	close_the_deal_each_NFT = "\t\t\t\t(unwrap-panic\n\t\t\t\t\t(as-contract (contract-call? '%s transfer u%d tx-sender agent-%d))\n\t\t\t\t)\n"
	close_the_deal_each_NFT_stx = "\t\t\t\t\t\t(unwrap-panic\n\t\t\t\t\t\t\t(as-contract (contract-call? '%s transfer u%d tx-sender agent-%d))\n\t\t\t\t\t\t)\n"

	trade = "(define-public (trade)\n\t(begin\n%s\t)\n)\n\n"
	trade_1 = "\t\t(unwrap-panic\n\t\t\t(begin\n%s\n\t\t\t\t(if (is-eq (var-get flag) true)\n\t\t\t\t\t(ok (var-set flag false))\n\t\t\t\t\t(ok false)\n\t\t\t\t)\n\t\t\t)\n\t\t)\n"
	trade_1_cond = "\t\t\t\t(if (is-eq tx-sender agent-%d)\n\t\t\t\t\t(begin\n%s\t\t\t\t\t\t(var-set agent-%d-status true)\n\t\t\t\t\t\t(var-set flag true)\n\t\t\t\t\t)\n\t\t\t\t\ttrue\n\t\t\t\t)\n"
	trade_1_each_NFT = "\t\t\t\t\t\t(unwrap-panic\n\t\t\t\t\t\t\t(contract-call? '%s transfer u%d tx-sender (as-contract tx-sender))\n\t\t\t\t\t\t)\n"
	trade_1_each_NFT_stx = "\n\t\t\t\t\t\t(unwrap-panic\n\t\t\t\t\t\t\t(stx-transfer? u%d tx-sender (as-contract tx-sender))\n\t\t\t\t\t\t)\n\n"

	# trade_2 = "\t\t(unwrap-panic\n\t\t\t(begin\n\t\t\t\t(unwrap-panic\n\t\t\t\t\t(contract-call? nft-address transfer tokenID tx-sender (as-contract tx-sender))\n\t\t\t\t)\n\t\t\t\t(if (is-eq stx-amount u0)\n\t\t\t\t\t(ok true)\n\t\t\t\t\t(stx-transfer? stx-amount tx-sender (as-contract tx-sender))\n\t\t\t\t)\n\t\t\t)\n\t\t)\n\n"
	trade_3 = "\t\t(if (and%s true)\n\t\t\t(begin\n\t\t\t\t(unwrap-panic\n\t\t\t\t\t(run-exchange)\n\t\t\t\t)\n\t\t\t)\n\t\t\ttrue\n\t\t)\n\t\t(ok true)\n"

	cancel = "(define-public (cancel)\n\t(begin\n\t\t(check-deal-status)\n\t\t(if (or%s)\n\t\t\t(begin\n\t\t\t\t(unwrap-panic\n\t\t\t\t\t(close-the-deal)\n\t\t\t\t)\n\t\t\t\t(ok true)\n\t\t\t)\n\t\t\t(ok false)\n\t\t)\n\t)\n)\n\n"

	stx_balance = "(define-public (stx-balance (address principal))\n\t(ok (stx-get-balance address))\n)\n"


	var_agents = ""
	var_agent_sign = ""

	temp_param_get = ""
	temp_param_is_eq = ""
	temp_run_exchange = ""
	temp_close_the_deal = ""
	temp_trade = ""

	agent_count = 0
	for eachDetail in contract_details:
		agent_count+=1

		var_agents+= agent_address%(agent_count,eachDetail)

		temp_param_get+= param_get%agent_count
		temp_param_is_eq+= param_is_eq%agent_count

		temp_stx = contract_details[eachDetail]["stx"]
		send_len = len(contract_details[eachDetail]["send"])
		receive_len = len(contract_details[eachDetail]["receive"])

		send_each_NFT = ""
		receive_each_NFT = ""
		temp_trade_1_each_NFT = ""

		Trade=True

		if send_len>0 or temp_stx<0:
			var_agent_sign+= agent_sign_false%agent_count
		else:
			Trade=False
			var_agent_sign+= agent_sign_true%agent_count
		
		for send in range(send_len):
			temp_nft_s = contract_details[eachDetail]["send"][send]

			temp_trade_1_each_NFT += trade_1_each_NFT%(temp_nft_s["nft_address"],temp_nft_s["nft_id"])

			if temp_stx <0:
				send_each_NFT+= close_the_deal_each_NFT_stx%(temp_nft_s["nft_address"],temp_nft_s["nft_id"],agent_count)
			else:
				send_each_NFT+= close_the_deal_each_NFT%(temp_nft_s["nft_address"],temp_nft_s["nft_id"],agent_count)
		
		for receive in range(receive_len):
			temp_nft_r = contract_details[eachDetail]["receive"][receive]

			if temp_stx >0:
				receive_each_NFT+= run_exchange_each_NFT_stx%(temp_nft_r["nft_address"],temp_nft_r["nft_id"],agent_count)
			else:
				receive_each_NFT+= run_exchange_cond%(temp_nft_r["nft_address"],temp_nft_r["nft_id"],agent_count)

		
		if temp_stx >0:
			temp_run_exchange+= run_exchange_cond_stx%(receive_each_NFT,temp_stx,agent_count)
			if Trade:
				temp_close_the_deal+= close_the_deal_cond%(agent_count,send_each_NFT,agent_count)
		elif temp_stx<0:

			temp_trade_1_each_NFT += trade_1_each_NFT_stx%(abs(temp_stx))

			temp_run_exchange+= receive_each_NFT
			if Trade:
				temp_close_the_deal+= close_the_deal_cond_stx%(agent_count,send_each_NFT,abs(temp_stx),agent_count,agent_count)
		else:
			temp_run_exchange+= receive_each_NFT
			if Trade:
				temp_close_the_deal+= close_the_deal_cond%(agent_count,send_each_NFT,agent_count)

			# temp_nft_r = contract_details[eachDetail]["receive"][0]
		if Trade:
			temp_trade+= trade_1_cond%(agent_count,temp_trade_1_each_NFT,agent_count)

			# temp_run_exchange+= run_exchange_cond_stx%(temp_nft_r["nft_address"],temp_nft_r["nft_id"],eachDetail,temp_stx,eachDetail)
			# temp_close_the_deal+= close_the_deal_cond%(agent_count,temp_nft_s["nft_address"],temp_nft_s["nft_id"],agent_count,agent_count)
			# elif temp_stx<0:
			#     # temp_run_exchange+= run_exchange_cond%(temp_nft_r["nft_address"],temp_nft_r["nft_id"],eachDetail)
			#     temp_close_the_deal+= close_the_deal_cond_stx%(agent_count,temp_nft_s["nft_address"],temp_nft_s["nft_id"],agent_count,abs(temp_stx),agent_count,agent_count)
			# else:
			#     # temp_run_exchange+= run_exchange_cond%(temp_nft_r["nft_address"],temp_nft_r["nft_id"],eachDetail)
			#     temp_close_the_deal+= close_the_deal_cond%(agent_count,temp_nft_s["nft_address"],temp_nft_s["nft_id"],agent_count,agent_count)


	# building FINAL full contract!
	CODE = CODE + trait

	# define var
	CODE = CODE + var_agents+"\n"
	CODE = CODE + var_agent_sign+"\n"

	CODE = CODE + flag+"\n"
	CODE = CODE + error+"\n"


	# Private/internal functions

	CODE = CODE + (check_deal%temp_param_get)
	CODE = CODE + (check_deal_status%temp_param_get)
	CODE = CODE + (run_exchange%temp_run_exchange)
	CODE = CODE + (close_the_deal%temp_close_the_deal)


	temp1 = trade_1%temp_trade
	temp3 = trade_3%temp_param_get
	temp = temp1+temp3 # + trade_2

	# Public functions
	CODE = CODE + trade%temp
	CODE = CODE +  cancel%temp_param_is_eq
	CODE = CODE + stx_balance

	return CODE