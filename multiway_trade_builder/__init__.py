from importlib import resources
from importlib.resources import read_text

def build_multiway_trade(networkType, data):

	if networkType == "testnet":
		network = "'ST2PABAF9FTAJYNFZH93XENAJ8FVY99RRM4DF2YCW.nft-trait.nft-trait"
	elif networkType == "mainnet":
		network = "'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait"
	else:
		errorMesg = "Error - Please Specify Correct Network!!"+"\n"
		errorMesg += "for Mainnet pass -> mainnet"+"\n"
		errorMesg += "for Testnet pass -> testnet"+"\n"
		return errorMesg
	
	##### here is where the data input gets used
	contract_details = data

	CODE = read_text("multiway_trade_builder","templet.clar")

	agent_sign_false = "(define-data-var agent-%d-status bool false)\n"
	agent_sign_true = "(define-data-var agent-%d-status bool true)\n"
	agent_address = "(define-constant agent-%d '%s)\n"

	param_get = " (var-get agent-%d-status)"
	param_is_eq = " (is-eq tx-sender agent-%d)"

	run_exchange_cond_stx = "\t(unwrap-panic (begin\n%s\t\t(as-contract (stx-transfer? u%d tx-sender agent-%d)))\n\t)\n"
	run_exchange_cond = "\t(unwrap-panic (as-contract (contract-call? '%s transfer u%d tx-sender agent-%d)))\n"
	run_exchange_each_NFT_stx = "\t\t(unwrap-panic (as-contract (contract-call? '%s transfer u%d tx-sender agent-%d)))\n"

	close_the_deal_cond_stx ="\t(if (is-eq (var-get agent-%d-status) true)\n\t(begin\n\t(unwrap-panic (begin\n%s\t\t(as-contract (stx-transfer? u%d tx-sender agent-%d)))\n\t)\n\t(var-set agent-%d-status false)\n\t)\n\ttrue\n\t)\n"
	close_the_deal_cond ="\t(if (is-eq (var-get agent-%d-status) true)\n\t(begin\n%s\t(var-set agent-%d-status false))\n\ttrue)\n"
	close_the_deal_each_NFT = "\t\t(unwrap-panic (as-contract (contract-call? '%s transfer u%d tx-sender agent-%d)))\n"
	close_the_deal_each_NFT_stx = "\t\t(unwrap-panic (as-contract (contract-call? '%s transfer u%d tx-sender agent-%d)))\n"

	trade_1_cond = "\t\t(if (is-eq tx-sender agent-%d)\n\t\t(begin\n%s\t\t(var-set agent-%d-status true)\n\t\t(var-set flag true))\n\t\ttrue)\n"
	trade_1_confirmation = "\t\t(asserts! (is-eq (var-get agent-%d-status) false) sender-already-confirmed)\n"
	trade_1_each_NFT = "\t\t(asserts! (is-ok (contract-call? '%s transfer u%d tx-sender (as-contract tx-sender))) cannot-escrow-nft )\n"
	trade_1_each_NFT_stx = "\t\t(asserts! (is-ok (stx-transfer? u%d tx-sender (as-contract tx-sender))) cannot-escrow-stx )\n"

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

		temp_trade_1_confirmation = trade_1_confirmation%(agent_count)

		send_each_NFT = ""
		receive_each_NFT = ""
		temp_trade_1_each_NFT = temp_trade_1_confirmation

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

		if Trade:
			temp_trade+= trade_1_cond%(agent_count,temp_trade_1_each_NFT,agent_count)

	CODE = CODE.format(
		network = network,
		agents = var_agents,
		agents_Signature = var_agent_sign,
		check_Agents_Signature = temp_param_get,
		release_Transactions = temp_run_exchange,
		cancel_Transactions = temp_close_the_deal,
		trading_Transactions = temp_trade,
		only_Agents = temp_param_is_eq
    )

	return CODE
