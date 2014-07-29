class Coind::Client

  def options
    @api.options
  end

  def initialize(options)
    @api = Coind::API.new(options)
  end

  # Safely copies wallet.dat to destination, which can be a directory or a path with filename.
  def backupwallet(destination)
    @api.request 'backupwallet', destination
  end

  def getbalance(minconf = 1)
    @api.request 'getbalance', nil, minconf
  end

  # Returns the block count of the latest block in the longest block chain.
  def getblockcount
    @api.request 'getblockcount'
  end

  # Returns the number of connections to other nodes.
  def getconnectioncount
    @api.request 'getconnectioncount'
  end

  # version 0.8 Attempts add or remove +node+ from the addnode list or try a connection to +node+ once.
  def addnode(node, command)
    @api.request 'addnode', node, command
  end

  def getaddednodeinfo(dns, node = nil)
    @api.request 'getaddednodeinfo', dns, node
  end

  # Returns an object containing various state info.
  def getinfo
    @api.request 'getinfo'
  end

  def getnewaddress(label = nil)
    @api.request 'getnewaddress', label
  end

  # Returns Object that has label names as keys, label balances (inaccurate) as values.
  def listlabels(minconf = 1)
    @api.request 'listaccounts', minconf
  end

  # Returns the current coin address for receiving payments to this +label+.
  def getlabeladdress(label)
    @api.request 'getaccountaddress', label
  end

  # Returns the list of addresses for the given +label+.
  def getaddressesbylabel(label)
    @api.request 'getaddressesbyaccount', label
  end

  # Returns the total amount received by addresses with +label+ in transactions
  # with at least +minconf+ confirmations.
  def getreceivedbylabel(label, minconf = 1)
    @api.request 'getreceivedbyaccount', label, minconf
  end

  # Returns the total amount received by +coinaddress+ in transactions with at least +minconf+ confirmations.
  def getreceivedbyaddress(coinaddress, minconf = 1)
    @api.request 'getreceivedbyaddress', coinaddress, minconf
  end

  # Get detailed information about +txid+
  def gettransaction(txid)
    @api.request 'gettransaction', txid
  end

  # Returns an array of objects containing:
  #
  #   :account       => the label of the receiving addresses
  #   :amount        => total amount received by addresses with this label
  #   :confirmations => number of confirmations of the most recent transaction included
  #
  def listreceivedbylabel(minconf = 1, includeempty = false)
    @api.request 'listreceivedbyaccount', minconf, includeempty
  end

  # Returns an array of objects containing:
  #
  #   :address       => receiving address
  #   :account       => the label of the receiving address
  #   :amount        => total amount received by the address
  #   :confirmations => number of confirmations of the most recent transaction included
  #
  # To get a list of accounts on the system, execute coind listreceivedbyaddress 0 true
  def listreceivedbyaddress(minconf = 1, includeempty = false)
    @api.request 'listreceivedbyaddress', minconf, includeempty
  end

  # Returns up to +count+ most recent transactions for +label+.
  def listtransactions(label = "*", count = 10, from = 0)
    @api.request 'listtransactions', label, count, from
  end

  # +amount+ is a real and is rounded to 8 decimal places
  def sendtoaddress(coinaddress, amount, comment = nil, comment_to = nil)
    @api.request 'sendtoaddress', coinaddress, amount, comment, comment_to
  end

  # Sets the label associated with the given address.
  def setlabel(coinaddress, label)
    @api.request 'setaccount', coinaddress, label
  end

  # Stop coind server.
  def stop
    @api.request 'stop'
  end

  # Return information about +coinaddress+.
  def validateaddress(coinaddress)
    @api.request 'validateaddress', coinaddress
  end

  # Sign a message using +coinaddress+.
  def signmessage(coinaddress, message)
    @api.request 'signmessage', coinaddress, message
  end

  # Verify signature made by +coinaddress+.
  def verifymessage(coinaddress, signature, message)
    @api.request 'verifymessage', coinaddress, signature, message
  end

  # version 0.7 Returns data about each connected node.
  def getpeerinfo
    @api.request 'getpeerinfo'
  end
  
  # version 0.7 Returns all transaction ids in memory pool
  def getrawmempool
    @api.request 'getrawmempool'
  end
  
  # version 0.7 Returns raw transaction representation for given transaction id.
  def getrawtransaction(txid, verbose = 0)
    @api.request 'getrawtransaction', txid, verbose
  end
  
  # version 0.7 Returns array of unspent transaction inputs in the wallet.  
  def listunspent(minconf = 1, maxconf = 999999)
    @api.request 'listunspent', minconf, maxconf
  end

  # version 0.7 version 0.7 Submits raw transaction (serialized, hex-encoded) to local node and network.  
  def sendrawtransaction(transaction)
    @api.request 'sendrawtransaction', transaction
  end

  # version 0.7 Produces a human-readable JSON object for a raw transaction.
  def decoderawtransaction(transaction)
    @api.request 'decoderawtransaction', transaction
  end

  # version 0.7 Creates a raw transaction spending given inputs.
  def createrawtransaction(input, output)
    @api.request 'createrawtransaction', input, output
  end

  # version 0.7 Signs a raw transaction
  def signrawtransaction(hex, txinfo = nil, keys = nil)
    @api.request 'signrawtransaction', hex, txinfo, keys
  end
  
  # version 0.9 Returns a new coin address, for receiving change. This is for use with raw transactions, NOT normal use.
  def getrawchangeaddress(label = nil)
    @api.request getrawchangeaddress label
  end

  def encryptwallet(passphrase)
    @api.request 'encryptwallet', passphrase
  end

  def walletpassphrase(passphrase, timeout = 20)
    @api.request 'walletpassphrase', passphrase, timeout
  end

  def walletlock
    @api.request 'walletlock'
  end

  alias add_node addnode
  alias get_add_node_info getaddednodeinfo
  alias encrypt encryptwallet
  alias unlock walletpassphrase
  alias lock walletlock
  alias label_address getlabeladdress
  alias addresses_by_label getaddressesbylabel
  alias balance getbalance
  alias block_count getblockcount
  alias connection_count getconnectioncount
  alias info getinfo
  alias new_address getnewaddress
  alias received_by_label getreceivedbylabel
  alias received_by_address getreceivedbyaddress
  alias transaction gettransaction
  alias labels listlabels
  alias list_received_by_label listreceivedbylabel
  alias list_received_by_address listreceivedbyaddress
  alias transactions listtransactions
  alias list_transactions listtransactions
  alias label= setlabel
  alias set_label setlabel
  alias validate_address validateaddress
  alias sign_message signmessage
  alias verify_message verifymessage
end
