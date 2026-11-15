"use client";

import { useState } from "react";

export default function DonatePage() {
  const [donationAmount, setDonationAmount] = useState<string>("10");
  const [selectedProject, setSelectedProject] = useState<string>("1");

  const amountNum = parseFloat(donationAmount) || 0;
  // Dynamic quadratic estimation simulation
  const estimatedMatch = Math.round(amountNum * 3.8);

  return (
    <div className="max-w-2xl mx-auto space-y-8">
      <div className="text-center space-y-2">
        <h1 className="text-3xl font-bold text-white">Contribute with Quadratic Matching</h1>
        <p className="text-sm text-gray-400">
          Your donation triggers matching funds based on the square root contribution formula.
        </p>
      </div>

      <div className="p-8 rounded-3xl bg-gray-900/60 border border-gray-800 space-y-6">
        <div className="space-y-2">
          <label className="text-sm font-medium text-gray-300">Select Project</label>
          <select
            value={selectedProject}
            onChange={(e) => setSelectedProject(e.target.value)}
            className="w-full px-4 py-3 rounded-xl bg-gray-950 border border-gray-800 text-white focus:outline-none focus:border-blue-500"
          >
            <option value="1">Project 1: Zero-Knowledge State Compression</option>
            <option value="2">Project 2: Solidity Invariant Fuzzer</option>
            <option value="3">Project 3: Decentralized Climate Registry</option>
          </select>
        </div>

        <div className="space-y-2">
          <label className="text-sm font-medium text-gray-300">Donation Amount (USDC)</label>
          <div className="relative">
            <input
              type="number"
              value={donationAmount}
              onChange={(e) => setDonationAmount(e.target.value)}
              className="w-full px-4 py-3 rounded-xl bg-gray-950 border border-gray-800 text-white focus:outline-none focus:border-blue-500 font-mono text-lg"
              placeholder="0.00"
              min="1"
            />
            <span className="absolute right-4 top-3.5 text-xs text-gray-500 font-medium">USDC</span>
          </div>
        </div>

        {/* Real-time Quadratic Funding Impact Card */}
        <div className="p-4 rounded-2xl bg-blue-950/40 border border-blue-900/50 space-y-2">
          <div className="flex items-center justify-between text-xs text-blue-300">
            <span>Direct Contribution</span>
            <span className="font-semibold text-white">${amountNum.toFixed(2)} USDC</span>
          </div>
          <div className="flex items-center justify-between text-xs text-blue-300">
            <span>Estimated Matching Boost</span>
            <span className="font-semibold text-emerald-400">+${estimatedMatch.toFixed(2)} USDC</span>
          </div>
          <div className="pt-2 border-t border-blue-900/50 flex items-center justify-between text-sm font-bold">
            <span className="text-white">Total Project Impact</span>
            <span className="text-emerald-400">${(amountNum + estimatedMatch).toFixed(2)} USDC</span>
          </div>
        </div>

        {/* Sybil Check Notice */}
        <div className="p-4 rounded-xl bg-gray-950/80 border border-gray-800 text-xs text-gray-400 space-y-1">
          <div className="font-semibold text-gray-300">🛡️ Sybil Resistance Status</div>
          <p>
            Gitcoin Passport / EAS attestation score: <strong className="text-emerald-400">28.4 / 20.0</strong> (Eligible for Quadratic Matching).
          </p>
        </div>

        <button className="w-full py-4 rounded-xl bg-blue-600 hover:bg-blue-500 font-bold text-white text-base shadow-lg shadow-blue-600/25 transition-all">
          Approve & Donate ${amountNum} USDC
        </button>
      </div>
    </div>
  );
}
