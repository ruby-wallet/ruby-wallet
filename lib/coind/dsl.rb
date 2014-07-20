module Coind::DSL
  def coind
    if self.class.respond_to?(:coin)
      @client ||= Coind::Client.new(self.class.coin.user, self.class.coin.pass, self.class.coin.options)
    else
      @client ||= Coind::Client.new(nil, nil)
    end
  end
  
  def username=(value)
    coind.user = value
  end
  
  def password=(value)
    coind.pass = value
  end
  
  def host=(value)
    coind.host = value
  end
  
  def port=(value)
    coind.port = value
  end
  
  def ssl=(value)
    coind.ssl = value
  end
  
  def username(value = nil)
    value ? coind.user = value : coin.user
  end
  
  def password(value = nil)
    value ? coind.pass = value : coin.pass
  end
  
  def host(value = nil)
    value ? coind.host = value : coin.host
  end
  
  def port(value = nil)
    value ? coind.port = value : coin.port
  end
  
  def ssl(value = nil)
    value.nil? ? coind.ssl : coind.ssl = value
  end
  
  def ssl?
    coind.ssl?
  end
  
  
  # Safely copies wallet.dat to destination, which can be a directory or a path with filename. 
  # Should add options to compress it and send it to a remote server
  def backupwallet(destination)
    coind.backupwallet destination
  end
  
  # Returns the account associated with the given address. 
  def getaccount(coinaddress)
    coind.getaccount coinaddress
  end
  
  # Returns the current coin address for receiving payments to this account. 
  def getaccountaddress(account)
    coind.getaccountaddress account
  end
  
  #	Returns the list of addresses for the given account. 
  def getaddressesbyaccount(account)
    coind.getaddressesbyaccount account
  end
  
  # If +account+ is not specified, returns the server's total available balance.
  # If +account+ is specified, returns the balance in the account.
  def getbalance(account = nil, minconf = 1)
    coind.getbalance account, minconf
  end
  
  # Dumps the block existing at specified height.
  # Note: this is not available in the official release
  def getblockbycount(height)
    coind.getblockbycount height
  end
  
  # Returns the number of blocks in the longest block chain.
  def getblockcount
    coind.getblockcount
  end
  
  # Returns the block number of the latest block in the longest block chain. 
  def getblocknumber
    coind.getblocknumber
  end
  
  # Returns the number of connections to other nodes.
  def getconnectioncount
    coind.getconnectioncount
  end
  
  # Returns the proof-of-work difficulty as a multiple of the minimum difficulty. 
  def getdifficulty
    coind.getdifficulty
  end
  
  # Returns true or false whether bitcoind is currently generating hashes 
  def getgenerate
    coind.getgenerate
  end
  
  # Returns a recent hashes per second performance measurement while generating. 
  def gethashespersec
    coind.gethashespersec
  end

  # Returns an object containing various state info. 
  def getinfo
    coind.getinfo
  end
    
  # Returns a new coin address for receiving payments. If +account+ is specified (recommended),
  # it is added to the address book so payments received with the address will be credited to +account+.
  def getnewaddress(account = nil)
    coind.getnewaddress account
  end
  
  # Returns the total amount received by addresses with +account+ in transactions
  # with at least +minconf+ confirmations. 
  def getreceivedbyaccount(account, minconf = 1)
    coind.getreceivedbyaccount account, minconf
  end
  
  # Returns the total amount received by +coinaddress+ in transactions with at least +minconf+ confirmations. 
  def getreceivedbyaddress(coinaddress, minconf = 1)
    coind.getreceivedbyaddress coinaddress, minconf
  end
  
  # Get detailed information about +txid+ 
  def gettransaction(txid)
    coind.gettransaction txid
  end
  
  # If +data+ is not specified, returns formatted hash data to work on:
  #
  #  :midstate => precomputed hash state after hashing the first half of the data
  #  :data     => block data
  #  :hash1    => formatted hash buffer for second hash
  #  :target   => little endian hash target 
  #
  # If +data+ is specified, tries to solve the block and returns true if it was successful.
  def getwork(data = nil)
    coind.getwork data
  end
  
  # List commands, or get help for a command. 
  def help(command = nil)
    coind.help command
  end
  
  # Returns Object that has account names as keys, account balances as values. 
  def listaccounts(minconf = 1)
    coind.listaccounts minconf
  end
  
  # Returns an array of objects containing:
  # 
  #   :account       => the account of the receiving addresses
  #   :amount        => total amount received by addresses with this account
  #   :confirmations => number of confirmations of the most recent transaction included
  #
  def listreceivedbyaccount(minconf = 1, includeempty = false)
    coind.listreceivedbyaccount minconf, includeempty
  end
  
  # Returns an array of objects containing:
  # 
  #   :address       => receiving address
  #   :account       => the account of the receiving address
  #   :amount        => total amount received by the address
  #   :confirmations => number of confirmations of the most recent transaction included 
  # 
  # To get a list of accounts on the system, execute coind listreceivedbyaddress 0 true
  def listreceivedbyaddress(minconf = 1, includeempty = false)
    coind.listreceivedbyaddress minconf, includeempty
  end
  
  # Returns up to +count+ most recent transactions for account +account+. 
  def listtransactions(account, count = 10)
    coind.listtransactions account, count
  end
  
  # Move from one account in your wallet to another. 
  def move(fromaccount, toaccount, amount, minconf = 1, comment = nil)
    coind.move fromaccount, toaccount, amount, minconf, comment
  end
  
  # +amount+ is a real and is rounded to 8 decimal places. Returns the transaction ID if successful. 
  def sendfrom(fromaccount, tobcoinaddress, amount, minconf = 1, comment = nil, comment_to = nil)
    coind.sendfrom fromaccount, tocoinaddress, amount, minconf, comment, comment_to
  end
  
  # +amount+ is a real and is rounded to 8 decimal places 
  def sendtoaddress(coinaddress, amount, comment = nil, comment_to = nil)
    coind.sendtoaddress coinaddress, amount, comment, comment_to
  end
  
  # Sets the account associated with the given address. 
  def setaccount(coinaddress, account)
    coind.setaccount coinaddress, account
  end
  
  # +generate+ is true or false to turn generation on or off.
  # Generation is limited to +genproclimit+ processors, -1 is unlimited.
  def setgenerate(generate, genproclimit = -1)
    coind.setgenerate generate, genproclimit
  end
  
  # Stop bitcoin server. 
  def stop
    coind.stop
  end
  
  # Return information about +coinaddress+. 
  def validateaddress(coinaddress)
    coind.validateaddress
  end

  def encryptwallet(passphrase)
    coind.encryptwallet passphrase
  end

  def walletpassphrase(passphrase, timeout = 20)
    coind.walletpassphrase passphrase, 20
  end

  def walletlock
    coind.walletlock
  end

  def dumpprivkey(coinaddress)
    coind.dumpprivkey coinaddress
  end

  alias encrypt encryptwallet
  alias unlock walletpassphrase
  alias lock walletlock
  alias private_key dumpprivkey
  alias account getaccount
  alias account_address getaccountaddress
  alias addresses_by_account getaddressesbyaccount
  alias balance getbalance
  alias block_by_count getblockbycount
  alias block_count getblockcount
  alias block_number getblocknumber
  alias connection_count getconnectioncount
  alias difficulty getdifficulty
  alias generate? getgenerate
  alias hashes_per_sec gethashespersec
  alias info getinfo
  alias new_address getnewaddress
  alias received_by_account getreceivedbyaccount
  alias received_by_address getreceivedbyaddress
  alias transaction gettransaction
  alias work getwork
  alias get_work getwork
  alias accounts listaccounts
  alias list_received_by_account listreceivedbyaccount
  alias list_received_by_address listreceivedbyaddress
  alias transactions listtransactions
  alias list_transactions listtransactions
  alias send_from sendfrom
  alias send_to_address sendtoaddress
  alias account= setaccount
  alias set_account setaccount
  alias generate= setgenerate
  alias set_generate setgenerate
  alias validate_address validateaddress
end
