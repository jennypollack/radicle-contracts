// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.7.5;

/// @notice A list of receivers to their weights, iterable and with random access
struct ReceiverWeights {
    mapping(address => ReceiverWeightsImpl.ReceiverWeightStored) data;
}

/// @notice Helper methods for receiver weights list.
/// The list works optimally if after applying a series of changes it's iterated over.
/// The list uses 1 word of storage per receiver with a non-zero weight.
library ReceiverWeightsImpl {
    using ReceiverWeightsImpl for ReceiverWeights;

    struct ReceiverWeightStored {
        address next;
        uint32 weightReceiver;
        uint32 weightProxy;
        uint32 isAttached;
    }

    address internal constant ADDR_ROOT = address(0);

    /// @notice Return the next non-zero receiver or proxy weight and its address.
    /// Removes all the items that have zero receiver and proxy weights found
    /// between the current and the next item from the list.
    /// Iterating over the whole list prunes all the zeroed items.
    /// @param oldCurrent The previously returned `current` or ADDR_ROOT to start iterating
    /// @param oldNext The previously returned `next` or ADDR_ROOT to start iterating
    /// @return current The receiver address, ADDR_ROOT if the end of the list was reached
    /// @return next A value passed as `oldNext` on the next call
    /// @return weightReceiver The receiver weight, may be zero if `weightProxy` is non-zero
    /// @return weightProxy The proxy weight, may be zero if `weightReceiver` is non-zero
    function nextWeightPruning(
        ReceiverWeights storage self,
        address oldCurrent,
        address oldNext
    )
        internal
        returns (
            address current,
            address next,
            uint32 weightReceiver,
            uint32 weightProxy
        )
    {
        if (oldCurrent == ADDR_ROOT) oldNext = self.data[ADDR_ROOT].next;
        current = oldNext;
        while (current != ADDR_ROOT) {
            weightReceiver = self.data[current].weightReceiver;
            weightProxy = self.data[current].weightProxy;
            next = self.data[current].next;
            if (weightReceiver != 0 || weightProxy != 0) break;
            delete self.data[current];
            current = next;
        }
        if (current != oldNext) self.data[oldCurrent].next = current;
    }

    /// @notice Return the next non-zero receiver or proxy weight and its address
    /// @param oldCurrent The previously returned `current` or ADDR_ROOT to start iterating
    /// @param oldNext The previously returned `next` or ADDR_ROOT to start iterating
    /// @return current The receiver address, ADDR_ROOT if the end of the list was reached
    /// @return next A value passed as `oldNext` on the next call
    /// @return weightReceiver The receiver weight, may be zero if `weightProxy` is non-zero
    /// @return weightProxy The proxy weight, may be zero if `weightReceiver` is non-zero
    function nextWeight(
        ReceiverWeights storage self,
        address oldCurrent,
        address oldNext
    )
        internal
        view
        returns (
            address current,
            address next,
            uint32 weightReceiver,
            uint32 weightProxy
        )
    {
        if (oldCurrent == ADDR_ROOT) oldNext = self.data[ADDR_ROOT].next;
        current = oldNext;
        while (current != ADDR_ROOT) {
            weightReceiver = self.data[current].weightReceiver;
            weightProxy = self.data[current].weightProxy;
            next = self.data[current].next;
            if (weightReceiver != 0 || weightProxy != 0) break;
            current = next;
        }
    }

    /// @notice Checks if the list is fully zeroed and takes no storage space.
    /// It means that either it was never used or that
    /// it's been pruned after removal of all the elements.
    /// @return True if the list is zeroed
    function isZeroed(ReceiverWeights storage self) internal view returns (bool) {
        return self.data[ADDR_ROOT].next == ADDR_ROOT;
    }

    /// @notice Set weight for a specific receiver
    /// @param receiver The receiver to set weight
    /// @param weight The weight to set
    /// @return previousWeight The previously set weight, may be zero
    function setReceiverWeight(
        ReceiverWeights storage self,
        address receiver,
        uint32 weight
    ) internal returns (uint32 previousWeight) {
        self.attachToList(receiver);
        previousWeight = self.data[receiver].weightReceiver;
        self.data[receiver].weightReceiver = weight;
    }

    /// @notice Set weight for a specific proxy
    /// @param proxy The proxy to set weight
    /// @param weight The weight to set
    /// @return previousWeight The previously set weight, may be zero
    function setProxyWeight(
        ReceiverWeights storage self,
        address proxy,
        uint32 weight
    ) internal returns (uint32 previousWeight) {
        self.attachToList(proxy);
        previousWeight = self.data[proxy].weightProxy;
        self.data[proxy].weightProxy = weight;
    }

    /// @notice Ensures that the weight for a specific receiver is attached to the list
    /// @param receiver The receiver whose weight should be attached
    function attachToList(ReceiverWeights storage self, address receiver) internal {
        require(receiver != ADDR_ROOT, "Invalid receiver address");
        if (self.data[receiver].isAttached == 0) {
            address rootNext = self.data[ADDR_ROOT].next;
            self.data[ADDR_ROOT].next = receiver;
            self.data[receiver].next = rootNext;
            self.data[receiver].isAttached = 1;
        }
    }
}
