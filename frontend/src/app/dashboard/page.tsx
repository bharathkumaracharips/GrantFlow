"use client";

import { useState } from "react";

export default function DashboardPage() {
  const [claimed, setClaimed] = useState(false);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-white">Project Owner Dashboard</h1>
        <p className="text-sm text-gray-400 mt-1">Manage project disbursements, review direct donations, and claim finalized matching payouts.</p>
      </div>

      <div className="grid md:grid-cols-3 gap-6">
        <div className="p-6 rounded-2xl bg-gray-900/60 border border-gray-800 space-y-2">
          <div className="text-xs text-gray-400">Total Direct Donations</div>
          <div className="text-2xl font-bold text-white">$4,250.00 USDC</div>
          <div className="text-xs text-blue-400">142 verified contributors</div>
        </div>
        <div className="p-6 rounded-2xl bg-gray-900/60 border border-gray-800 space-y-2">
          <div className="text-xs text-gray-400">Finalized Matching Share</div>
          <div className="text-2xl font-bold text-emerald-400">$14,800.00 USDC</div>
          <div className="text-xs text-emerald-500">Merkle Root Verified On-Chain</div>
        </div>
        <div className="p-6 rounded-2xl bg-gray-900/60 border border-gray-800 space-y-2">
          <div className="text-xs text-gray-400">Claim Status</div>
          <div className="text-2xl font-bold text-white">{claimed ? "Claimed" : "Ready to Claim"}</div>
          <div className="text-xs text-gray-500">Payout Address: 0x391...921</div>
        </div>
      </div>

      <div className="p-8 rounded-3xl bg-gray-900/60 border border-gray-800 space-y-6">
        <h2 className="text-xl font-bold text-white">Execute Merkle Payout Claim</h2>
        <p className="text-sm text-gray-400">
          The challenge period for Round 3 has elapsed. You can now submit your cryptographic Merkle proof to <code className="text-blue-400">DistributionManager.sol</code> to withdraw your accumulated direct donations and quadratic matching share.
        </p>

        <div className="p-4 rounded-xl bg-gray-950 font-mono text-xs text-gray-400 space-y-1 overflow-x-auto">
          <div>Root: 0x9f83a48e7...b6e2d1</div>
          <div>Proof: [0x4a1...29, 0xbb8...02, 0x11e...ff]</div>
          <div>Recipient: 0x391...921</div>
        </div>

        <button
          onClick={() => setClaimed(true)}
          disabled={claimed}
          className={`px-6 py-3 rounded-xl font-bold text-white transition-all ${
            claimed
              ? "bg-gray-800 text-gray-500 cursor-not-allowed"
              : "bg-emerald-600 hover:bg-emerald-500 shadow-lg shadow-emerald-600/25"
          }`}
        >
          {claimed ? "Payout Disbursed ✓" : "Claim Payout ($19,050.00 USDC)"}
        </button>
      </div>
    </div>
  );
}
