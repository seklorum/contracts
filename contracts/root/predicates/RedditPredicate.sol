// File: contracts/contracts-package/IERC20.sol

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/predicate/ERC20Predicate.sol

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/common/lib/BytesLib.sol

pragma solidity ^0.5.2;

library BytesLib {
    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes memory) {
        bytes memory tempBytes;
        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(
                0x40,
                and(
                    add(add(end, iszero(add(length, mload(_preBytes)))), 31),
                    not(31) // Round down to the nearest 32 bytes.
                )
            )
        }
        return tempBytes;
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_bytes.length >= (_start + _length));
        bytes memory tempBytes;
        assembly {
            switch iszero(_length)
                case 0 {
                    // Get a location of some free memory and store it in tempBytes as
                    // Solidity does for memory variables.
                    tempBytes := mload(0x40)

                    // The first word of the slice result is potentially a partial
                    // word read from the original array. To read it, we calculate
                    // the length of that partial word and start copying that many
                    // bytes into the array. The first word we copy will start with
                    // data we don't care about, but the last `lengthmod` bytes will
                    // land at the beginning of the contents of the new array. When
                    // we're done copying, we overwrite the full first word with
                    // the actual length of the slice.
                    let lengthmod := and(_length, 31)

                    // The multiplication in the next line is necessary
                    // because when slicing multiples of 32 bytes (lengthmod == 0)
                    // the following copy loop was copying the origin's length
                    // and then ending prematurely not copying everything it should.
                    let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                    let end := add(mc, _length)

                    for {
                        // The multiplication in the next line has the same exact purpose
                        // as the one above.
                        let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                    } lt(mc, end) {
                        mc := add(mc, 0x20)
                        cc := add(cc, 0x20)
                    } {
                        mstore(mc, mload(cc))
                    }

                    mstore(tempBytes, _length)

                    //update free-memory pointer
                    //allocating the array padded to 32 bytes like the compiler does now
                    mstore(0x40, and(add(mc, 31), not(31)))
                }
                //if we want a zero-length slice let's just return a zero-length array
                default {
                    tempBytes := mload(0x40)
                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    // Pad a bytes array to 32 bytes
    function leftPad(bytes memory _bytes) internal pure returns (bytes memory) {
        // may underflow if bytes.length < 32. Hence using SafeMath.sub
        bytes memory newBytes = new bytes(SafeMath.sub(32, _bytes.length));
        return concat(newBytes, _bytes);
    }

    function toBytes32(bytes memory b) internal pure returns (bytes32) {
        require(b.length >= 32, "Bytes array should atleast be 32 bytes");
        bytes32 out;
        for (uint256 i = 0; i < 32; i++) {
            out |= bytes32(b[i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function toBytes4(bytes memory b) internal pure returns (bytes4 result) {
        assembly {
            result := mload(add(b, 32))
        }
    }

    function fromBytes32(bytes32 x) internal pure returns (bytes memory) {
        bytes memory b = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            b[i] = bytes1(uint8(uint256(x) / (2**(8 * (31 - i)))));
        }
        return b;
    }

    function fromUint(uint256 _num) internal pure returns (bytes memory _ret) {
        _ret = new bytes(32);
        assembly {
            mstore(add(_ret, 32), _num)
        }
    }

    function toUint(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= (_start + 32));
        uint256 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= (_start + 20));
        address tempAddress;
        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }
}

// File: contracts/common/lib/Common.sol

pragma solidity ^0.5.2;

library Common {
    function getV(bytes memory v, uint16 chainId) public pure returns (uint8) {
        if (chainId > 0) {
            return uint8(BytesLib.toUint(BytesLib.leftPad(v), 0) - (chainId * 2) - 8);
        } else {
            return uint8(BytesLib.toUint(BytesLib.leftPad(v), 0));
        }
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) public view returns (bool) {
        uint256 length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    // convert bytes to uint8
    function toUint8(bytes memory _arg) public pure returns (uint8) {
        return uint8(_arg[0]);
    }

    function toUint16(bytes memory _arg) public pure returns (uint16) {
        return (uint16(uint8(_arg[0])) << 8) | uint16(uint8(_arg[1]));
    }
}

// File: openzeppelin-solidity/contracts/math/Math.sol

pragma solidity ^0.5.2;

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

// File: contracts/common/lib/RLPEncode.sol

// Library for RLP encoding a list of bytes arrays.
// Modeled after ethereumjs/rlp (https://github.com/ethereumjs/rlp)
// [Very] modified version of Sam Mayo's library.
pragma solidity ^0.5.2;

library RLPEncode {
    // Encode an item (bytes memory)
    function encodeItem(bytes memory self) internal pure returns (bytes memory) {
        bytes memory encoded;
        if (self.length == 1 && uint8(self[0] & 0xFF) < 0x80) {
            encoded = new bytes(1);
            encoded = self;
        } else {
            encoded = BytesLib.concat(encodeLength(self.length, 128), self);
        }
        return encoded;
    }

    // Encode a list of items
    function encodeList(bytes[] memory self) internal pure returns (bytes memory) {
        bytes memory encoded;
        for (uint256 i = 0; i < self.length; i++) {
            encoded = BytesLib.concat(encoded, encodeItem(self[i]));
        }
        return BytesLib.concat(encodeLength(encoded.length, 192), encoded);
    }

    // Hack to encode nested lists. If you have a list as an item passed here, included
    // pass = true in that index. E.g.
    // [item, list, item] --> pass = [false, true, false]
    // function encodeListWithPasses(bytes[] memory self, bool[] pass) internal pure returns (bytes memory) {
    //   bytes memory encoded;
    //   for (uint i=0; i < self.length; i++) {
    // 		if (pass[i] == true) {
    // 			encoded = BytesLib.concat(encoded, self[i]);
    // 		} else {
    // 			encoded = BytesLib.concat(encoded, encodeItem(self[i]));
    // 		}
    //   }
    //   return BytesLib.concat(encodeLength(encoded.length, 192), encoded);
    // }

    // Generate the prefix for an item or the entire list based on RLP spec
    function encodeLength(uint256 L, uint256 offset) internal pure returns (bytes memory) {
        if (L < 56) {
            bytes memory prefix = new bytes(1);
            prefix[0] = bytes1(uint8(L + offset));
            return prefix;
        } else {
            // lenLen is the length of the hex representation of the data length
            uint256 lenLen;
            uint256 i = 0x1;

            while (L / i != 0) {
                lenLen++;
                i *= 0x100;
            }

            bytes memory prefix0 = getLengthBytes(offset + 55 + lenLen);
            bytes memory prefix1 = getLengthBytes(L);
            return BytesLib.concat(prefix0, prefix1);
        }
    }

    function getLengthBytes(uint256 x) internal pure returns (bytes memory b) {
        // Figure out if we need 1 or two bytes to express the length.
        // 1 byte gets us to max 255
        // 2 bytes gets us to max 65535 (no payloads will be larger than this)
        uint256 nBytes = 1;
        if (x > 255) {
            nBytes = 2;
        }

        b = new bytes(nBytes);
        // Encode the length and return it
        for (uint256 i = 0; i < nBytes; i++) {
            b[i] = bytes1(uint8(x / (2**(8 * (nBytes - 1 - i)))));
        }
    }
}

// File: solidity-rlp/contracts/RLPReader.sol

/*
 * @author Hamdi Allam hamdi.allam97@gmail.com
 * Please reach out with any questions or concerns
 */
pragma solidity ^0.5.0;

library RLPReader {
    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint256 len;
        uint256 memPtr;
    }

    struct Iterator {
        RLPItem item; // Item that's being iterated over.
        uint256 nextPtr; // Position of the next item in the list.
    }

    /*
     * @dev Returns the next element in the iteration. Reverts if it has not next element.
     * @param self The iterator.
     * @return The next element in the iteration.
     */
    function next(Iterator memory self) internal pure returns (RLPItem memory) {
        require(hasNext(self));

        uint256 ptr = self.nextPtr;
        uint256 itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    /*
     * @dev Returns true if the iteration has more elements.
     * @param self The iterator.
     * @return true if the iteration has more elements.
     */
    function hasNext(Iterator memory self) internal pure returns (bool) {
        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    /*
     * @param item RLP encoded bytes
     */
    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {
        uint256 memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    /*
     * @dev Create an iterator. Reverts if item is not a list.
     * @param self The RLP item.
     * @return An 'Iterator' over the item.
     */
    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {
        require(isList(self));

        uint256 ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    /*
     * @param item RLP encoded bytes
     */
    function rlpLen(RLPItem memory item) internal pure returns (uint256) {
        return item.len;
    }

    /*
     * @param item RLP encoded bytes
     */
    function payloadLen(RLPItem memory item) internal pure returns (uint256) {
        return item.len - _payloadOffset(item.memPtr);
    }

    /*
     * @param item RLP encoded list in bytes
     */
    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {
        require(isList(item));

        uint256 items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint256 memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 dataLen;
        for (uint256 i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    // @return indicator whether encoded payload is a list. negate this function call for isData.
    function isList(RLPItem memory item) internal pure returns (bool) {
        if (item.len == 0) return false;

        uint8 byte0;
        uint256 memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }

    /** RLPItem conversions into data types **/

    // @returns raw rlp encoding in bytes
    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {
        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;

        uint256 ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    // any non-zero byte is considered true
    function toBoolean(RLPItem memory item) internal pure returns (bool) {
        require(item.len == 1);
        uint256 result;
        uint256 memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        return result == 0 ? false : true;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {
        // 1 byte for the length prefix
        require(item.len == 21);

        return address(toUint(item));
    }

    function toUint(RLPItem memory item) internal pure returns (uint256) {
        require(item.len > 0 && item.len <= 33);

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset;

        uint256 result;
        uint256 memPtr = item.memPtr + offset;
        assembly {
            result := mload(memPtr)

            // shfit to the correct location if neccesary
            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    // enforces 32 byte length
    function toUintStrict(RLPItem memory item) internal pure returns (uint256) {
        // one byte prefix
        require(item.len == 33);

        uint256 result;
        uint256 memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        require(item.len > 0);

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint256 destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }

    /*
     * Private Helpers
     */

    // @return number of payload items inside an encoded list.
    function numItems(RLPItem memory item) private pure returns (uint256) {
        if (item.len == 0) return 0;

        uint256 count = 0;
        uint256 currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            count++;
        }

        return count;
    }

    // @return entire rlp item byte length
    function _itemLength(uint256 memPtr) private pure returns (uint256) {
        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) itemLen = 1;
        else if (byte0 < STRING_LONG_START) itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                /* 32 byte word size */
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    // @return number of bytes until the data
    function _payloadOffset(uint256 memPtr) private pure returns (uint256) {
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)) return 1;
        else if (byte0 < LIST_SHORT_START)
            // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }

    /*
     * @param src Pointer to source
     * @param dest Pointer to destination
     * @param len Amount of memory to copy from the source
     */
    function copy(
        uint256 src,
        uint256 dest,
        uint256 len
    ) private pure {
        if (len == 0) return;

        // copy as many word sizes as possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        // left over bytes. Mask is used to remove unwanted bytes from the word
        uint256 mask = 256**(WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}

// File: contracts/root/withdrawManager/IWithdrawManager.sol

pragma solidity ^0.5.2;

contract IWithdrawManager {
    function createExitQueue(address token) external;

    function verifyInclusion(
        bytes calldata data,
        uint8 offset,
        bool verifyTxInclusion
    ) external view returns (uint256 age);

    function addExitToQueue(
        address exitor,
        address childToken,
        address rootToken,
        uint256 exitAmountOrTokenId,
        bytes32 txHash,
        bool isRegularExit,
        uint256 priority
    ) external;

    function addInput(
        uint256 exitId,
        uint256 age,
        address utxoOwner,
        address token
    ) external;

    function challengeExit(
        uint256 exitId,
        uint256 inputId,
        bytes calldata challengeData,
        address adjudicatorPredicate
    ) external;
}

// File: contracts/root/depositManager/IDepositManager.sol

pragma solidity ^0.5.2;

interface IDepositManager {
    function depositEther() external payable;

    function transferAssets(
        address _token,
        address _user,
        uint256 _amountOrNFTId
    ) external;

    function depositERC20(address _token, uint256 _amount) external;

    function depositERC721(address _token, uint256 _tokenId) external;
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/common/misc/ProxyStorage.sol

pragma solidity ^0.5.2;

contract ProxyStorage is Ownable {
    address internal proxyTo;
}

// File: contracts/common/governance/IGovernance.sol

pragma solidity ^0.5.2;

interface IGovernance {
    function update(address target, bytes calldata data) external;
}

// File: contracts/common/governance/Governable.sol

pragma solidity ^0.5.2;

contract Governable {
    IGovernance public governance;

    constructor(address _governance) public {
        governance = IGovernance(_governance);
    }

    modifier onlyGovernance() {
        require(msg.sender == address(governance), "Only governance contract is authorized");
        _;
    }
}

// File: contracts/common/Registry.sol

pragma solidity ^0.5.2;

contract Registry is Governable {
    // @todo hardcode constants
    bytes32 private constant WETH_TOKEN = keccak256("wethToken");
    bytes32 private constant DEPOSIT_MANAGER = keccak256("depositManager");
    bytes32 private constant STAKE_MANAGER = keccak256("stakeManager");
    bytes32 private constant VALIDATOR_SHARE = keccak256("validatorShare");
    bytes32 private constant WITHDRAW_MANAGER = keccak256("withdrawManager");
    bytes32 private constant CHILD_CHAIN = keccak256("childChain");
    bytes32 private constant STATE_SENDER = keccak256("stateSender");
    bytes32 private constant SLASHING_MANAGER = keccak256("slashingManager");

    address public erc20Predicate;
    address public erc721Predicate;

    mapping(bytes32 => address) public contractMap;
    mapping(address => address) public rootToChildToken;
    mapping(address => address) public childToRootToken;
    mapping(address => bool) public proofValidatorContracts;
    mapping(address => bool) public isERC721;

    enum Type {Invalid, ERC20, ERC721, Custom}
    struct Predicate {
        Type _type;
    }
    mapping(address => Predicate) public predicates;

    event TokenMapped(address indexed rootToken, address indexed childToken);
    event ProofValidatorAdded(address indexed validator, address indexed from);
    event ProofValidatorRemoved(address indexed validator, address indexed from);
    event PredicateAdded(address indexed predicate, address indexed from);
    event PredicateRemoved(address indexed predicate, address indexed from);
    event ContractMapUpdated(bytes32 indexed key, address indexed previousContract, address indexed newContract);

    constructor(address _governance) public Governable(_governance) {}

    function updateContractMap(bytes32 _key, address _address) external onlyGovernance {
        emit ContractMapUpdated(_key, contractMap[_key], _address);
        contractMap[_key] = _address;
    }

    /**
     * @dev Map root token to child token
     * @param _rootToken Token address on the root chain
     * @param _childToken Token address on the child chain
     * @param _isERC721 Is the token being mapped ERC721
     */
    function mapToken(
        address _rootToken,
        address _childToken,
        bool _isERC721
    ) external onlyGovernance {
        require(_rootToken != address(0x0) && _childToken != address(0x0), "INVALID_TOKEN_ADDRESS");
        rootToChildToken[_rootToken] = _childToken;
        childToRootToken[_childToken] = _rootToken;
        isERC721[_rootToken] = _isERC721;
        IWithdrawManager(contractMap[WITHDRAW_MANAGER]).createExitQueue(_rootToken);
        emit TokenMapped(_rootToken, _childToken);
    }

    function addErc20Predicate(address predicate) public onlyGovernance {
        require(predicate != address(0x0), "Can not add null address as predicate");
        erc20Predicate = predicate;
        addPredicate(predicate, Type.ERC20);
    }

    function addErc721Predicate(address predicate) public onlyGovernance {
        erc721Predicate = predicate;
        addPredicate(predicate, Type.ERC721);
    }

    function addPredicate(address predicate, Type _type) public onlyGovernance {
        require(predicates[predicate]._type == Type.Invalid, "Predicate already added");
        predicates[predicate]._type = _type;
        emit PredicateAdded(predicate, msg.sender);
    }

    function removePredicate(address predicate) public onlyGovernance {
        require(predicates[predicate]._type != Type.Invalid, "Predicate does not exist");
        delete predicates[predicate];
        emit PredicateRemoved(predicate, msg.sender);
    }

    function getValidatorShareAddress() public view returns (address) {
        return contractMap[VALIDATOR_SHARE];
    }

    function getWethTokenAddress() public view returns (address) {
        return contractMap[WETH_TOKEN];
    }

    function getDepositManagerAddress() public view returns (address) {
        return contractMap[DEPOSIT_MANAGER];
    }

    function getStakeManagerAddress() public view returns (address) {
        return contractMap[STAKE_MANAGER];
    }

    function getSlashingManagerAddress() public view returns (address) {
        return contractMap[SLASHING_MANAGER];
    }

    function getWithdrawManagerAddress() public view returns (address) {
        return contractMap[WITHDRAW_MANAGER];
    }

    function getChildChainAndStateSender() public view returns (address, address) {
        return (contractMap[CHILD_CHAIN], contractMap[STATE_SENDER]);
    }

    function isTokenMapped(address _token) public view returns (bool) {
        return rootToChildToken[_token] != address(0x0);
    }

    function isTokenMappedAndIsErc721(address _token) public view returns (bool) {
        require(isTokenMapped(_token), "TOKEN_NOT_MAPPED");
        return isERC721[_token];
    }

    function isTokenMappedAndGetPredicate(address _token) public view returns (address) {
        if (isTokenMappedAndIsErc721(_token)) {
            return erc721Predicate;
        }
        return erc20Predicate;
    }

    function isChildTokenErc721(address childToken) public view returns (bool) {
        address rootToken = childToRootToken[childToken];
        require(rootToken != address(0x0), "Child token is not mapped");
        return isERC721[rootToken];
    }
}

// File: contracts/common/mixin/ChainIdMixin.sol

pragma solidity ^0.5.2;

contract ChainIdMixin {
    bytes public constant networkId = hex"3A99";
    uint256 public constant CHAINID = 15001;
}

// File: contracts/root/RootChainStorage.sol

pragma solidity ^0.5.2;

contract RootChainHeader {
    event NewHeaderBlock(
        address indexed proposer,
        uint256 indexed headerBlockId,
        uint256 indexed reward,
        uint256 start,
        uint256 end,
        bytes32 root
    );
    // housekeeping event
    event ResetHeaderBlock(address indexed proposer, uint256 indexed headerBlockId);
    struct HeaderBlock {
        bytes32 root;
        uint256 start;
        uint256 end;
        uint256 createdAt;
        address proposer;
    }
}

contract RootChainStorage is ProxyStorage, RootChainHeader, ChainIdMixin {
    bytes32 public heimdallId;
    uint8 public constant VOTE_TYPE = 2;

    uint16 internal constant MAX_DEPOSITS = 10000;
    uint256 public _nextHeaderBlock = MAX_DEPOSITS;
    uint256 internal _blockDepositId = 1;
    mapping(uint256 => HeaderBlock) public headerBlocks;
    Registry internal registry;
}

// File: contracts/staking/stakeManager/IStakeManager.sol

pragma solidity ^0.5.2;

contract IStakeManager {
    // validator replacement
    function startAuction(
        uint256 validatorId,
        uint256 amount,
        bool acceptDelegation,
        bytes calldata signerPubkey
    ) external;

    function confirmAuctionBid(uint256 validatorId, uint256 heimdallFee) external;

    function transferFunds(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external returns (bool);

    function delegationDeposit(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external returns (bool);

    function stake(
        uint256 amount,
        uint256 heimdallFee,
        bool acceptDelegation,
        bytes calldata signerPubkey
    ) external;

    function unstake(uint256 validatorId) external;

    function totalStakedFor(address addr) external view returns (uint256);

    function stakeFor(
        address user,
        uint256 amount,
        uint256 heimdallFee,
        bool acceptDelegation,
        bytes memory signerPubkey
    ) public;

    function checkSignatures(
        uint256 blockInterval,
        bytes32 voteHash,
        bytes32 stateRoot,
        address proposer,
        bytes memory sigs
    ) public returns (uint256);

    function updateValidatorState(uint256 validatorId, int256 amount) public;

    function ownerOf(uint256 tokenId) public view returns (address);

    function slash(bytes memory slashingInfoList) public returns (uint256);

    function validatorStake(uint256 validatorId) public view returns (uint256);

    function epoch() public view returns (uint256);

    function withdrawalDelay() public view returns (uint256);
}

// File: contracts/root/IRootChain.sol

pragma solidity ^0.5.2;

interface IRootChain {
    function slash() external;

    function submitHeaderBlock(bytes calldata data, bytes calldata sigs) external;

    function getLastChildBlock() external view returns (uint256);

    function currentHeaderBlock() external view returns (uint256);
}

// File: contracts/root/RootChain.sol

pragma solidity ^0.5.2;

contract RootChain is RootChainStorage, IRootChain {
    using SafeMath for uint256;
    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;

    modifier onlyDepositManager() {
        require(msg.sender == registry.getDepositManagerAddress(), "UNAUTHORIZED_DEPOSIT_MANAGER_ONLY");
        _;
    }

    function submitHeaderBlock(bytes calldata data, bytes calldata sigs) external {
        (address proposer, uint256 start, uint256 end, bytes32 rootHash, bytes32 accountHash, uint256 _borChainID) = abi
            .decode(data, (address, uint256, uint256, bytes32, bytes32, uint256));
        require(CHAINID == _borChainID, "Invalid bor chain id");

        require(_buildHeaderBlock(proposer, start, end, rootHash), "INCORRECT_HEADER_DATA");

        // check if it is better to keep it in local storage instead
        IStakeManager stakeManager = IStakeManager(registry.getStakeManagerAddress());
        uint256 _reward = stakeManager.checkSignatures(
            end.sub(start).add(1),
            /**
                prefix 01 to data
                01 represents positive vote on data and 00 is negative vote
                malicious validator can try to send 2/3 on negative vote so 01 is appended
             */
            keccak256(abi.encodePacked(bytes(hex"01"), data)),
            accountHash,
            proposer,
            sigs
        );

        require(_reward != 0, "Invalid checkpoint");
        emit NewHeaderBlock(proposer, _nextHeaderBlock, _reward, start, end, rootHash);
        _nextHeaderBlock = _nextHeaderBlock.add(MAX_DEPOSITS);
        _blockDepositId = 1;
    }

    function updateDepositId(uint256 numDeposits) external onlyDepositManager returns (uint256 depositId) {
        depositId = currentHeaderBlock().add(_blockDepositId);
        // deposit ids will be (_blockDepositId, _blockDepositId + 1, .... _blockDepositId + numDeposits - 1)
        _blockDepositId = _blockDepositId.add(numDeposits);
        require(
            // Since _blockDepositId is initialized to 1; only (MAX_DEPOSITS - 1) deposits per header block are allowed
            _blockDepositId <= MAX_DEPOSITS,
            "TOO_MANY_DEPOSITS"
        );
    }

    function getLastChildBlock() external view returns (uint256) {
        return headerBlocks[currentHeaderBlock()].end;
    }

    function slash() external {
        //TODO: future implementation
    }

    function currentHeaderBlock() public view returns (uint256) {
        return _nextHeaderBlock.sub(MAX_DEPOSITS);
    }

    function _buildHeaderBlock(
        address proposer,
        uint256 start,
        uint256 end,
        bytes32 rootHash
    ) private returns (bool) {
        uint256 nextChildBlock;
        /*
    The ID of the 1st header block is MAX_DEPOSITS.
    if _nextHeaderBlock == MAX_DEPOSITS, then the first header block is yet to be submitted, hence nextChildBlock = 0
    */
        if (_nextHeaderBlock > MAX_DEPOSITS) {
            nextChildBlock = headerBlocks[currentHeaderBlock()].end + 1;
        }
        if (nextChildBlock != start) {
            return false;
        }

        HeaderBlock memory headerBlock = HeaderBlock({
            root: rootHash,
            start: nextChildBlock,
            end: end,
            createdAt: now,
            proposer: proposer
        });

        headerBlocks[_nextHeaderBlock] = headerBlock;
        return true;
    }

    // Housekeeping function. @todo remove later
    function setNextHeaderBlock(uint256 _value) public onlyOwner {
        require(_value % MAX_DEPOSITS == 0, "Invalid value");
        for (uint256 i = _value; i < _nextHeaderBlock; i += MAX_DEPOSITS) {
            delete headerBlocks[i];
        }
        _nextHeaderBlock = _value;
        _blockDepositId = 1;
        emit ResetHeaderBlock(msg.sender, _nextHeaderBlock);
    }

    // Housekeeping function. @todo remove later
    function setHeimdallId(string memory _heimdallId) public onlyOwner {
        heimdallId = keccak256(abi.encodePacked(_heimdallId));
    }
}

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

pragma solidity ^0.5.2;

/**
 * @title IERC165
 * @dev https://eips.ethereum.org/EIPS/eip-165
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol

pragma solidity ^0.5.2;

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public;
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol

pragma solidity ^0.5.2;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `safeTransfer`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4);
}

// File: openzeppelin-solidity/contracts/utils/Address.sol

pragma solidity ^0.5.2;

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

// File: openzeppelin-solidity/contracts/drafts/Counters.sol

pragma solidity ^0.5.2;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the SafeMath
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

// File: openzeppelin-solidity/contracts/introspection/ERC165.sol

pragma solidity ^0.5.2;

/**
 * @title ERC165
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    /*
     * 0x01ffc9a7 ===
     *     bytes4(keccak256('supportsInterface(bytes4)'))
     */

    /**
     * @dev a mapping of interface id to whether or not it's supported
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
     * @dev A contract implementing SupportsInterfaceWithLookup
     * implement ERC165 itself
     */
    constructor() internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev implement supportsInterface(bytes4) using a lookup table
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev internal method for registering an interface
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol

pragma solidity ^0.5.2;

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping(uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping(address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     * 0x80ac58cd ===
     *     bytes4(keccak256('balanceOf(address)')) ^
     *     bytes4(keccak256('ownerOf(uint256)')) ^
     *     bytes4(keccak256('approve(address,uint256)')) ^
     *     bytes4(keccak256('getApproved(uint256)')) ^
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) ^
     *     bytes4(keccak256('isApprovedForAll(address,address)')) ^
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) ^
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
     */

    constructor() public {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    /**
     * @dev Gets the balance of the specified address
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0));
        return _ownedTokensCount[owner].current();
    }

    /**
     * @dev Gets the owner of the specified token ID
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

// File: contracts/root/withdrawManager/ExitNFT.sol

pragma solidity ^0.5.2;

contract ExitNFT is ERC721 {
    Registry internal registry;

    modifier onlyWithdrawManager() {
        require(msg.sender == registry.getWithdrawManagerAddress(), "UNAUTHORIZED_WITHDRAW_MANAGER_ONLY");
        _;
    }

    constructor(address _registry) public {
        registry = Registry(_registry);
    }

    function mint(address _owner, uint256 _tokenId) external onlyWithdrawManager {
        _mint(_owner, _tokenId);
    }

    function burn(uint256 _tokenId) external onlyWithdrawManager {
        _burn(_tokenId);
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }
}

// File: contracts/root/withdrawManager/WithdrawManagerStorage.sol

pragma solidity ^0.5.2;

contract ExitsDataStructure {
    struct Input {
        address utxoOwner;
        address predicate;
        address token;
    }

    struct PlasmaExit {
        uint256 receiptAmountOrNFTId;
        bytes32 txHash;
        address owner;
        address token;
        bool isRegularExit;
        address predicate;
        // Mapping from age of input to Input
        mapping(uint256 => Input) inputs;
    }
}

contract WithdrawManagerHeader is ExitsDataStructure {
    event Withdraw(uint256 indexed exitId, address indexed user, address indexed token, uint256 amount);

    event ExitStarted(
        address indexed exitor,
        uint256 indexed exitId,
        address indexed token,
        uint256 amount,
        bool isRegularExit
    );

    event ExitUpdated(uint256 indexed exitId, uint256 indexed age, address signer);
    event ExitPeriodUpdate(uint256 indexed oldExitPeriod, uint256 indexed newExitPeriod);

    event ExitCancelled(uint256 indexed exitId);
}

contract WithdrawManagerStorage is ProxyStorage, WithdrawManagerHeader {
    // 0.5 week = 7 * 86400 / 2 = 302400
    uint256 public HALF_EXIT_PERIOD = 302400;

    // Bonded exits collaterized at 0.1 ETH
    uint256 internal constant BOND_AMOUNT = 10**17;

    Registry internal registry;
    RootChain internal rootChain;

    mapping(uint128 => bool) isKnownExit;
    mapping(uint256 => PlasmaExit) public exits;
    // mapping with token => (owner => exitId) keccak(token+owner) keccak(token+owner+tokenId)
    mapping(bytes32 => uint256) public ownerExits;
    mapping(address => address) public exitsQueues;
    ExitNFT public exitNft;

    // ERC721, ERC20 and Weth transfers require 155000, 100000, 52000 gas respectively
    // Processing each exit in a while loop iteration requires ~52000 gas (@todo check if this changed)
    // uint32 constant internal ITERATION_GAS = 52000;

    // So putting an upper limit of 155000 + 52000 + leeway
    uint32 public ON_FINALIZE_GAS_LIMIT = 300000;

    uint256 public exitWindow;
}

interface IPredicate {
    /**
     * @notice Verify the deprecation of a state update
     * @param exit ABI encoded PlasmaExit data
     * @param inputUtxo ABI encoded Input UTXO data
     * @param challengeData RLP encoded data of the challenge reference tx that encodes the following fields
     * headerNumber Header block number of which the reference tx was a part of
     * blockProof Proof that the block header (in the child chain) is a leaf in the submitted merkle root
     * blockNumber Block number of which the reference tx is a part of
     * blockTime Reference tx block time
     * blocktxRoot Transactions root of block
     * blockReceiptsRoot Receipts root of block
     * receipt Receipt of the reference transaction
     * receiptProof Merkle proof of the reference receipt
     * branchMask Merkle proof branchMask for the receipt
     * logIndex Log Index to read from the receipt
     * tx Challenge transaction
     * txProof Merkle proof of the challenge tx
     * @return Whether or not the state is deprecated
     */
    function verifyDeprecation(
        bytes calldata exit,
        bytes calldata inputUtxo,
        bytes calldata challengeData
    ) external returns (bool);

    function interpretStateUpdate(bytes calldata state) external view returns (bytes memory);

    function onFinalizeExit(bytes calldata data) external;
}

contract PredicateUtils is ExitsDataStructure, ChainIdMixin {
    using RLPReader for RLPReader.RLPItem;

    // Bonded exits collaterized at 0.1 ETH
    uint256 private constant BOND_AMOUNT = 10**17;

    IWithdrawManager internal withdrawManager;
    IDepositManager internal depositManager;

    modifier onlyWithdrawManager() {
        require(msg.sender == address(withdrawManager), "ONLY_WITHDRAW_MANAGER");
        _;
    }

    modifier isBondProvided() {
        require(msg.value == BOND_AMOUNT, "Invalid Bond amount");
        _;
    }

    function onFinalizeExit(bytes calldata data) external onlyWithdrawManager {
        (, address token, address exitor, uint256 tokenId) = decodeExitForProcessExit(data);
        depositManager.transferAssets(token, exitor, tokenId);
    }

    function sendBond() internal {
        address(uint160(address(withdrawManager))).transfer(BOND_AMOUNT);
    }

    function getAddressFromTx(RLPReader.RLPItem[] memory txList)
        internal
        pure
        returns (address signer, bytes32 txHash)
    {
        bytes[] memory rawTx = new bytes[](9);
        for (uint8 i = 0; i <= 5; i++) {
            rawTx[i] = txList[i].toBytes();
        }
        rawTx[6] = networkId;
        rawTx[7] = hex""; // [7] and [8] have something to do with v, r, s values
        rawTx[8] = hex"";

        txHash = keccak256(RLPEncode.encodeList(rawTx));
        signer = ecrecover(
            txHash,
            Common.getV(txList[6].toBytes(), Common.toUint16(networkId)),
            bytes32(txList[7].toUint()),
            bytes32(txList[8].toUint())
        );
    }

    function decodeExit(bytes memory data) internal pure returns (PlasmaExit memory) {
        (address owner, address token, uint256 amountOrTokenId, bytes32 txHash, bool isRegularExit) = abi.decode(
            data,
            (address, address, uint256, bytes32, bool)
        );
        return
            PlasmaExit(
                amountOrTokenId,
                txHash,
                owner,
                token,
                isRegularExit,
                address(0) /* predicate value is not required */
            );
    }

    function decodeExitForProcessExit(bytes memory data)
        internal
        pure
        returns (
            uint256 exitId,
            address token,
            address exitor,
            uint256 tokenId
        )
    {
        (exitId, token, exitor, tokenId) = abi.decode(data, (uint256, address, address, uint256));
    }

    function decodeInputUtxo(bytes memory data)
        internal
        pure
        returns (
            uint256 age,
            address signer,
            address predicate,
            address token
        )
    {
        (age, signer, predicate, token) = abi.decode(data, (uint256, address, address, address));
    }
}

contract IErcPredicate is IPredicate, PredicateUtils {
    enum ExitType {Invalid, OutgoingTransfer, IncomingTransfer, Burnt}

    struct ExitTxData {
        uint256 amountOrToken;
        bytes32 txHash;
        address childToken;
        address signer;
        ExitType exitType;
    }

    struct ReferenceTxData {
        uint256 closingBalance;
        uint256 age;
        address childToken;
        address rootToken;
    }

    uint256 internal constant MAX_LOGS = 10;

    constructor(address _withdrawManager, address _depositManager) public {
        withdrawManager = IWithdrawManager(_withdrawManager);
        depositManager = IDepositManager(_depositManager);
    }
}

contract ERC20Predicate is IErcPredicate {
    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;
    using SafeMath for uint256;

    // keccak256('Deposit(address,address,uint256,uint256,uint256)')
    bytes32 constant DEPOSIT_EVENT_SIG = 0x4e2ca0515ed1aef1395f66b5303bb5d6f1bf9d61a353fa53f73f8ac9973fa9f6;
    // keccak256('Withdraw(address,address,uint256,uint256,uint256)')
    bytes32 constant WITHDRAW_EVENT_SIG = 0xebff2602b3f468259e1e99f613fed6691f3a6526effe6ef3e768ba7ae7a36c4f;
    // keccak256('LogTransfer(address,address,address,uint256,uint256,uint256,uint256,uint256)')
    bytes32 constant LOG_TRANSFER_EVENT_SIG = 0xe6497e3ee548a3372136af2fcb0696db31fc6cf20260707645068bd3fe97f3c4;
    // keccak256('LogFeeTransfer(address,address,address,uint256,uint256,uint256,uint256,uint256)')
    bytes32 constant LOG_FEE_TRANSFER_EVENT_SIG = 0x4dfe1bbbcf077ddc3e01291eea2d5c70c2b422b415d95645b9adcfd678cb1d63;

    // keccak256('withdraw(uint256)').slice(0, 4)
    bytes4 constant WITHDRAW_FUNC_SIG = 0x2e1a7d4d;
    // keccak256('transfer(address,uint256)').slice(0, 4)
    bytes4 constant TRANSFER_FUNC_SIG = 0xa9059cbb;

    Registry registry;

    constructor(
        address _withdrawManager,
        address _depositManager,
        address _registry
    ) public IErcPredicate(_withdrawManager, _depositManager) {
        registry = Registry(_registry);
    }

    function startExitWithBurntTokens(bytes calldata data) external {
        RLPReader.RLPItem[] memory referenceTxData = data.toRlpItem().toList();
        bytes memory receipt = referenceTxData[6].toBytes();
        RLPReader.RLPItem[] memory inputItems = receipt.toRlpItem().toList();
        uint256 logIndex = referenceTxData[9].toUint();
        require(logIndex < MAX_LOGS, "Supporting a max of 10 logs");
        uint256 age = withdrawManager.verifyInclusion(
            data,
            0, /* offset */
            false /* verifyTxInclusion */
        );
        inputItems = inputItems[3].toList()[logIndex].toList(); // select log based on given logIndex

        // "address" (contract address that emitted the log) field in the receipt
        address childToken = RLPReader.toAddress(inputItems[0]);
        bytes memory logData = inputItems[2].toBytes();
        inputItems = inputItems[1].toList(); // topics
        // now, inputItems[i] refers to i-th (0-based) topic in the topics array
        // event Withdraw(address indexed token, address indexed from, uint256 amountOrTokenId, uint256 input1, uint256 output1)
        require(bytes32(inputItems[0].toUint()) == WITHDRAW_EVENT_SIG, "Not a withdraw event signature");
        address rootToken = address(RLPReader.toUint(inputItems[1]));
        require(
            msg.sender == address(inputItems[2].toUint()), // from
            "Withdrawer and burn exit tx do not match"
        );
        uint256 exitAmount = BytesLib.toUint(logData, 0); // amountOrTokenId
        withdrawManager.addExitToQueue(
            msg.sender,
            childToken,
            rootToken,
            exitAmount,
            bytes32(0x0),
            true, /* isRegularExit */
            age << 1
        );
    }

    /**
     * @notice Start an exit by referencing the preceding (reference) transaction
     * @param data RLP encoded data of the reference tx (proof-of-funds of exitor) that encodes the following fields
     * headerNumber Header block number of which the reference tx was a part of
     * blockProof Proof that the block header (in the child chain) is a leaf in the submitted merkle root
     * blockNumber Block number of which the reference tx is a part of
     * blockTime Reference tx block time
     * blocktxRoot Transactions root of block
     * blockReceiptsRoot Receipts root of block
     * receipt Receipt of the reference transaction
     * receiptProof Merkle proof of the reference receipt
     * branchMask Merkle proof branchMask for the receipt
     * logIndex Log Index to read from the receipt
     * @param exitTx Signed exit transaction (outgoing transfer or burn)
     * @return address rootToken that the exit corresponds to
     * @return uint256 exitAmount
     */
    function startExitForOutgoingErc20Transfer(bytes calldata data, bytes calldata exitTx)
        external
        payable
        isBondProvided
        returns (
            address, /* rootToken */
            uint256 /* exitAmount */
        )
    {
        // referenceTx is a proof-of-funds of the party who signed the exit tx
        // If the exitor is exiting with outgoing transfer, it will refer to their own preceding tx
        // If the exitor is exiting with incoming transfer, it will refer to the counterparty's preceding tx
        RLPReader.RLPItem[] memory referenceTx = data.toRlpItem().toList();

        // Validate the exitTx - This may be an in-flight tx, so inclusion will not be checked
        ExitTxData memory exitTxData = processExitTx(exitTx);
        require(exitTxData.signer == msg.sender, "Should be an outgoing transfer");

        // Process the receipt of the referenced tx
        ReferenceTxData memory referenceTxData = processReferenceTx(
            referenceTx[6].toBytes(), // receipt
            referenceTx[9].toUint(), // logIndex
            msg.sender, // participant whose proof-of-funds are to be checked in the reference tx
            false /* isChallenge */
        );
        require(
            exitTxData.childToken == referenceTxData.childToken,
            "Reference and exit tx do not correspond to the same child token"
        );
        // exitTxData.amountOrToken represents the total exit amount based on the in-flight exit type
        // re-using the variable here to avoid stack overflow
        exitTxData.amountOrToken = validateSequential(exitTxData, referenceTxData);

        // Checking the inclusion of the receipt of the preceding tx is enough
        // It is inconclusive to check the inclusion of the signed tx, hence verifyTxInclusion = false
        // age is a measure of the position of the tx in the side chain
        referenceTxData.age = withdrawManager
            .verifyInclusion(
            data,
            0, /* offset */
            false /* verifyTxInclusion */
        )
            .add(referenceTxData.age); // Add the logIndex and oIndex from the receipt

        sendBond(); // send BOND_AMOUNT to withdrawManager

        // last bit is to differentiate whether the sender or receiver of the in-flight tx is starting an exit
        uint256 exitId = referenceTxData.age << 1;
        exitId |= 1; // since msg.sender == exitTxData.signer
        withdrawManager.addExitToQueue(
            msg.sender,
            referenceTxData.childToken,
            referenceTxData.rootToken,
            exitTxData.amountOrToken,
            exitTxData.txHash,
            false, /* isRegularExit */
            exitId
        );
        withdrawManager.addInput(exitId, referenceTxData.age, msg.sender, referenceTxData.rootToken);
        return (referenceTxData.rootToken, exitTxData.amountOrToken);
    }

    /**
     * @notice Start an exit by referencing the preceding (reference) transaction
     * @param data RLP encoded data of the reference tx(s) that encodes the following fields for each tx
     * headerNumber Header block number of which the reference tx was a part of
     * blockProof Proof that the block header (in the child chain) is a leaf in the submitted merkle root
     * blockNumber Block number of which the reference tx is a part of
     * blockTime Reference tx block time
     * blocktxRoot Transactions root of block
     * blockReceiptsRoot Receipts root of block
     * receipt Receipt of the reference transaction
     * receiptProof Merkle proof of the reference receipt
     * branchMask Merkle proof branchMask for the receipt
     * logIndex Log Index to read from the receipt
     * @param exitTx Signed exit transaction (incoming transfer)
     * @return address rootToken that the exit corresponds to
     * @return uint256 exitAmount
     */
    function startExitForIncomingErc20Transfer(bytes calldata data, bytes calldata exitTx)
        external
        payable
        isBondProvided
        returns (
            address, /* rootToken */
            uint256 /* exitAmount */
        )
    {
        // referenceTx is a proof-of-funds of the party who signed the exit tx
        // If the exitor is exiting with outgoing transfer, it will refer to their own preceding tx
        // If the exitor is exiting with incoming transfer, it will refer to the counterparty's preceding tx
        RLPReader.RLPItem[] memory referenceTx = data.toRlpItem().toList();

        // Validate the exitTx - This may be an in-flight tx, so inclusion will not be checked
        ExitTxData memory exitTxData = processExitTx(exitTx);
        require(exitTxData.signer != msg.sender, "Should be an incoming transfer");
        // Process the receipt (i.e. proof-of-funds of the counterparty) of the referenced tx
        ReferenceTxData memory referenceTxData = processReferenceTx(
            referenceTx[6].toBytes(), // receipt
            referenceTx[9].toUint(), // logIndex
            exitTxData.signer,
            false /* isChallenge */
        );
        require(
            exitTxData.childToken == referenceTxData.childToken,
            "Reference and exit tx do not correspond to the same child token"
        );
        exitTxData.amountOrToken = validateSequential(exitTxData, referenceTxData);

        // Checking the inclusion of the receipt of the preceding tx is enough
        // It is inconclusive to check the inclusion of the signed tx, hence verifyTxInclusion = false
        // age is a measure of the position of the tx in the side chain
        referenceTxData.age = withdrawManager
            .verifyInclusion(
            data,
            0, /* offset */
            false /* verifyTxInclusion */
        )
            .add(referenceTxData.age); // Add the logIndex and oIndex from the receipt

        ReferenceTxData memory _referenceTxData;
        // referenceTx.length > 10 means the exitor sent along another input UTXO to the exit tx
        // This will be used to exit with the pre-existing balance on the chain along with the couterparty signed exit tx
        if (referenceTx.length > 10) {
            _referenceTxData = processReferenceTx(
                referenceTx[16].toBytes(), // receipt
                referenceTx[19].toUint(), // logIndex
                msg.sender, // participant
                false /* isChallenge */
            );
            require(
                _referenceTxData.childToken == referenceTxData.childToken,
                "child tokens in the referenced txs do not match"
            );
            require(
                _referenceTxData.rootToken == referenceTxData.rootToken,
                "root tokens in the referenced txs do not match"
            );
            _referenceTxData.age = withdrawManager
                .verifyInclusion(
                data,
                10, /* offset */
                false /* verifyTxInclusion */
            )
                .add(_referenceTxData.age);
        }

        sendBond(); // send BOND_AMOUNT to withdrawManager

        // last bit is to differentiate whether the sender or receiver of the in-flight tx is starting an exit
        uint256 exitId = Math.max(referenceTxData.age, _referenceTxData.age) << 1;
        withdrawManager.addExitToQueue(
            msg.sender,
            referenceTxData.childToken,
            referenceTxData.rootToken,
            exitTxData.amountOrToken.add(_referenceTxData.closingBalance),
            exitTxData.txHash,
            false, /* isRegularExit */
            exitId
        );
        withdrawManager.addInput(exitId, referenceTxData.age, exitTxData.signer, referenceTxData.rootToken);
        // If exitor did not have pre-exiting balance on the chain => _referenceTxData has default values;
        // In that case, the following input acts as a "dummy" input UTXO to challenge token spends by the exitor
        withdrawManager.addInput(exitId, _referenceTxData.age, msg.sender, referenceTxData.rootToken);
        return (referenceTxData.rootToken, exitTxData.amountOrToken.add(_referenceTxData.closingBalance));
    }

    /**
     * @notice Verify the deprecation of a state update
     * @param exit ABI encoded PlasmaExit data
     * @param inputUtxo ABI encoded Input UTXO data
     * @param challengeData RLP encoded data of the challenge reference tx that encodes the following fields
     * headerNumber Header block number of which the reference tx was a part of
     * blockProof Proof that the block header (in the child chain) is a leaf in the submitted merkle root
     * blockNumber Block number of which the reference tx is a part of
     * blockTime Reference tx block time
     * blocktxRoot Transactions root of block
     * blockReceiptsRoot Receipts root of block
     * receipt Receipt of the reference transaction
     * receiptProof Merkle proof of the reference receipt
     * branchMask Merkle proof branchMask for the receipt
     * logIndex Log Index to read from the receipt
     * tx Challenge transaction
     * txProof Merkle proof of the challenge tx
     * @return Whether or not the state is deprecated
     */
    function verifyDeprecation(
        bytes calldata exit,
        bytes calldata inputUtxo,
        bytes calldata challengeData
    ) external returns (bool) {
        PlasmaExit memory _exit = decodeExit(exit);
        (uint256 age, address signer, , address childToken) = decodeInputUtxo(inputUtxo);
        RLPReader.RLPItem[] memory _challengeData = challengeData.toRlpItem().toList();
        ExitTxData memory challengeTxData = processChallengeTx(_challengeData[10].toBytes());
        require(
            challengeTxData.signer == signer,
            "Challenge tx not signed by the party who signed the input UTXO to the exit"
        );

        // receipt alone is not enough for a challenge. It is required to check that the challenge tx was included as well
        ReferenceTxData memory referenceTxData = processReferenceTx(
            _challengeData[6].toBytes(), // receipt
            _challengeData[9].toUint(), // logIndex
            challengeTxData.signer,
            true /* isChallenge */
        );
        referenceTxData.age = withdrawManager
            .verifyInclusion(
            challengeData,
            0,
            true /* verifyTxInclusion */
        )
            .add(referenceTxData.age);
        require(
            referenceTxData.childToken == childToken && challengeTxData.childToken == childToken,
            "LogTransferReceipt, challengeTx token and challenged utxo token do not match"
        );
        if (referenceTxData.age < age) {
            // this block shows that the exitor used an older, already checkpointed tx as in-flight to start an exit;
            // only in that case, we can allow the challenge age to be < exit age
            require(_exit.txHash == challengeTxData.txHash, "Cannot challenge with the exit tx");
        } else {
            require(_exit.txHash != challengeTxData.txHash, "Cannot challenge with the exit tx");
        }
        return true;
    }

    /**
     * @notice Parse a ERC20 LogTransfer event in the receipt
     * @param state abi encoded (data, participant, verifyInclusion)
     * data is RLP encoded reference tx receipt that encodes the following fields
     * headerNumber Header block number of which the reference tx was a part of
     * blockProof Proof that the block header (in the child chain) is a leaf in the submitted merkle root
     * blockNumber Block number of which the reference tx is a part of
     * blockTime Reference tx block time
     * blocktxRoot Transactions root of block
     * blockReceiptsRoot Receipts root of block
     * receipt Receipt of the reference transaction
     * receiptProof Merkle proof of the reference receipt
     * branchMask Merkle proof branchMask for the receipt
     * logIndex Log Index to read from the receipt
     * tx Challenge transaction
     * txProof Merkle proof of the challenge tx
     * @return abi encoded (closingBalance, ageOfUtxo, childToken, rootToken)
     */
    function interpretStateUpdate(bytes calldata state) external view returns (bytes memory) {
        // isChallenge - Is the state being parsed for a challenge
        (bytes memory _data, address participant, bool verifyInclusion, bool isChallenge) = abi.decode(
            state,
            (bytes, address, bool, bool)
        );
        RLPReader.RLPItem[] memory referenceTx = _data.toRlpItem().toList();
        bytes memory receipt = referenceTx[6].toBytes();
        uint256 logIndex = referenceTx[9].toUint();
        require(logIndex < MAX_LOGS, "Supporting a max of 10 logs");
        RLPReader.RLPItem[] memory inputItems = receipt.toRlpItem().toList();
        inputItems = inputItems[3].toList()[logIndex].toList(); // select log based on given logIndex
        ReferenceTxData memory data;
        data.childToken = RLPReader.toAddress(inputItems[0]); // "address" (contract address that emitted the log) field in the receipt
        bytes memory logData = inputItems[2].toBytes();
        inputItems = inputItems[1].toList(); // topics
        data.rootToken = address(RLPReader.toUint(inputItems[1]));
        if (isChallenge) {
            processChallenge(inputItems, participant);
        } else {
            (data.closingBalance, data.age) = processStateUpdate(inputItems, logData, participant);
        }
        data.age = data.age.add(logIndex.mul(MAX_LOGS));
        if (verifyInclusion) {
            data.age = data.age.add(
                withdrawManager.verifyInclusion(
                    _data,
                    0,
                    false /* verifyTxInclusion */
                )
            );
        }
        return abi.encode(data.closingBalance, data.age, data.childToken, data.rootToken);
    }

    /**
     * @dev Process the reference tx to start a MoreVP style exit
     * @param receipt Receipt of the reference transaction
     * @param logIndex Log Index to read from the receipt
     * @param participant Either of exitor or a counterparty depending on the type of exit
     * @param isChallenge Whether it is a challenge or start exit operation
     * @return ReferenceTxData Parsed reference tx data
     */
    function processReferenceTx(
        bytes memory receipt,
        uint256 logIndex,
        address participant,
        bool isChallenge
    ) internal view returns (ReferenceTxData memory data) {
        require(logIndex < MAX_LOGS, "Supporting a max of 10 logs");
        RLPReader.RLPItem[] memory inputItems = receipt.toRlpItem().toList();
        inputItems = inputItems[3].toList()[logIndex].toList(); // select log based on given logIndex
        data.childToken = RLPReader.toAddress(inputItems[0]); // "address" (contract address that emitted the log) field in the receipt
        bytes memory logData = inputItems[2].toBytes();
        inputItems = inputItems[1].toList(); // topics
        // now, inputItems[i] refers to i-th (0-based) topic in the topics array
        bytes32 eventSignature = bytes32(inputItems[0].toUint()); // inputItems[0] is the event signature
        data.rootToken = address(RLPReader.toUint(inputItems[1]));

        // When child chain is started, since child matic is a genenis contract at 0x1010,
        // the root token corresponding to matic is not known, hence child token address is emitted in LogFeeTransfer events.
        // Fix that anomaly here
        if (eventSignature == LOG_FEE_TRANSFER_EVENT_SIG) {
            data.rootToken = registry.childToRootToken(data.rootToken);
        }

        if (isChallenge) {
            processChallenge(inputItems, participant);
        } else {
            (data.closingBalance, data.age) = processStateUpdate(inputItems, logData, participant);
        }
        // In our construction, we give an incrementing age to every log in a receipt
        data.age = data.age.add(logIndex.mul(MAX_LOGS));
    }

    function validateSequential(ExitTxData memory exitTxData, ReferenceTxData memory referenceTxData)
        internal
        pure
        returns (uint256 exitAmount)
    {
        // The closing balance of the referenced tx should be >= exit amount in exitTx
        require(referenceTxData.closingBalance >= exitTxData.amountOrToken, "Exiting with more tokens than referenced");
        // If exit tx has is an outgoing transfer from exitor's perspective, exit with closingBalance minus sent amount
        if (exitTxData.exitType == ExitType.OutgoingTransfer) {
            return referenceTxData.closingBalance.sub(exitTxData.amountOrToken);
        }
        // If exit tx was burnt tx, exit with the entire referenced balance not just that was burnt, since user only gets one chance to exit MoreVP style
        if (exitTxData.exitType == ExitType.Burnt) {
            return referenceTxData.closingBalance;
        }
        // If exit tx has is an incoming transfer from exitor's perspective, exit with exitAmount
        return exitTxData.amountOrToken;
    }

    function processChallenge(RLPReader.RLPItem[] memory inputItems, address participant) internal pure {
        bytes32 eventSignature = bytes32(inputItems[0].toUint());
        // event Withdraw(address indexed token, address indexed from, uint256 amountOrTokenId, uint256 input1, uint256 output1)
        // event Log(Fee)Transfer(
        //   address indexed token, address indexed from, address indexed to,
        //   uint256 amountOrTokenId, uint256 input1, uint256 input2, uint256 output1, uint256 output2)
        require(
            eventSignature == WITHDRAW_EVENT_SIG ||
                eventSignature == LOG_TRANSFER_EVENT_SIG ||
                eventSignature == LOG_FEE_TRANSFER_EVENT_SIG,
            "Log signature doesnt qualify as a valid spend"
        );
        require(
            participant == address(inputItems[2].toUint()), // from
            "participant and referenced tx do not match"
        );
        // oIndex is always 0 for the 2 scenarios above, hence not returning it
    }

    /**
     * @notice Parse the state update and check if this predicate recognizes it
     * @param inputItems inputItems[i] refers to i-th (0-based) topic in the topics array in the log
     * @param logData Data field (unindexed params) in the log
     */
    function processStateUpdate(
        RLPReader.RLPItem[] memory inputItems,
        bytes memory logData,
        address participant
    ) internal pure returns (uint256 closingBalance, uint256 oIndex) {
        bytes32 eventSignature = bytes32(inputItems[0].toUint());
        if (eventSignature == DEPOSIT_EVENT_SIG || eventSignature == WITHDRAW_EVENT_SIG) {
            // event Deposit(address indexed token, address indexed from, uint256 amountOrTokenId, uint256 input1, uint256 output1)
            // event Withdraw(address indexed token, address indexed from, uint256 amountOrTokenId, uint256 input1, uint256 output1)
            require(
                participant == address(inputItems[2].toUint()), // from
                "Withdrawer and referenced tx do not match"
            );
            closingBalance = BytesLib.toUint(logData, 64); // output1
        } else if (eventSignature == LOG_TRANSFER_EVENT_SIG || eventSignature == LOG_FEE_TRANSFER_EVENT_SIG) {
            // event Log(Fee)Transfer(
            //   address indexed token, address indexed from, address indexed to,
            //   uint256 amountOrTokenId, uint256 input1, uint256 input2, uint256 output1, uint256 output2)
            if (participant == address(inputItems[2].toUint())) {
                // A. Participant transferred tokens
                closingBalance = BytesLib.toUint(logData, 96); // output1
            } else if (participant == address(inputItems[3].toUint())) {
                // B. Participant received tokens
                closingBalance = BytesLib.toUint(logData, 128); // output2
                oIndex = 1;
            } else {
                revert("tx / log doesnt concern the participant");
            }
        } else {
            revert("Exit type not supported");
        }
    }

    /**
     * @notice Process the transaction to start a MoreVP style exit from
     * @param exitTx Signed exit transaction
     */
    function processExitTx(bytes memory exitTx) internal view returns (ExitTxData memory txData) {
        RLPReader.RLPItem[] memory txList = exitTx.toRlpItem().toList();
        require(txList.length == 9, "MALFORMED_WITHDRAW_TX");
        txData.childToken = RLPReader.toAddress(txList[3]); // corresponds to "to" field in tx
        (txData.signer, txData.txHash) = getAddressFromTx(txList);
        if (txData.signer == msg.sender) {
            // exit tx is signed by exitor
            (txData.amountOrToken, txData.exitType) = processExitTxSender(RLPReader.toBytes(txList[5]));
        } else {
            // exitor is a counterparty in the provided tx
            txData.amountOrToken = processExitTxCounterparty(RLPReader.toBytes(txList[5]));
            txData.exitType = ExitType.IncomingTransfer;
        }
    }

    /**
     * @notice Process the challenge transaction
     * @param exitTx Challenge transaction
     * @return ExitTxData Parsed challenge transaction data
     */
    function processChallengeTx(bytes memory exitTx) internal pure returns (ExitTxData memory txData) {
        RLPReader.RLPItem[] memory txList = exitTx.toRlpItem().toList();
        require(txList.length == 9, "MALFORMED_WITHDRAW_TX");
        txData.childToken = RLPReader.toAddress(txList[3]); // corresponds to "to" field in tx
        (txData.signer, txData.txHash) = getAddressFromTx(txList);
        // during a challenge, the tx signer must be the first party
        (txData.amountOrToken, ) = processExitTxSender(RLPReader.toBytes(txList[5]));
    }

    /**
     * @dev Processes transaction from the "signer / sender" perspective
     * @param txData Transaction input data
     * @return exitAmount Number of tokens burnt or sent
     * @return burnt Whether the tokens were burnt
     */
    function processExitTxSender(bytes memory txData) internal pure returns (uint256 amount, ExitType exitType) {
        bytes4 funcSig = BytesLib.toBytes4(BytesLib.slice(txData, 0, 4));
        if (funcSig == WITHDRAW_FUNC_SIG) {
            amount = BytesLib.toUint(txData, 4);
            exitType = ExitType.Burnt;
        } else if (funcSig == TRANSFER_FUNC_SIG) {
            amount = BytesLib.toUint(txData, 36);
            exitType = ExitType.OutgoingTransfer;
        } else {
            revert("Exit tx type not supported");
        }
    }

    /**
     * @dev Processes transaction from the "receiver" perspective
     * @param txData Transaction input data
     * @return exitAmount Number of tokens received
     */
    function processExitTxCounterparty(bytes memory txData) internal view returns (uint256 exitAmount) {
        bytes4 funcSig = BytesLib.toBytes4(BytesLib.slice(txData, 0, 4));
        require(funcSig == TRANSFER_FUNC_SIG, "Only supports exiting from transfer txs");
        require(
            msg.sender == address(BytesLib.toUint(txData, 4)), // to
            "Exitor should be the receiver in the exit tx"
        );
        exitAmount = BytesLib.toUint(txData, 36); // value
    }
}

// File: contracts/predicate/RedditPredicate.sol

pragma solidity >=0.5.0 <0.6.0;

contract RedditPredicate is ERC20Predicate {
    constructor(
        address _withdrawManager,
        address _depositManager,
        address _registry
    ) public ERC20Predicate(_withdrawManager, _depositManager, _registry) {}

    function onFinalizeExit(bytes calldata data) external onlyWithdrawManager {
        (, address token, address exitor, uint256 amount) = decodeExitForProcessExit(data);
        uint256 toTransfer = IERC20(token).balanceOf(address(depositManager));
        if (toTransfer > 0) {
            if (toTransfer > amount) {
                toTransfer = amount;
            }
            depositManager.transferAssets(token, exitor, toTransfer);
            amount = amount.sub(toTransfer);
        }
        if (amount > 0) {
            // predicate should have been whitelisted as a minter
            // perform the mint operation for amount in the reddit token contract
        }
    }
}