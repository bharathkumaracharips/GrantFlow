import Link from "next/link";

export default function Home() {
  return (
    <div className="space-y-16 py-6">
      {/* Hero Section */}
      <section className="text-center space-y-6 max-w-3xl mx-auto pt-8">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-medium bg-blue-950/60 text-blue-400 border border-blue-800/60">
          <span className="w-2 h-2 rounded-full bg-blue-400 animate-pulse" />
          Round 4 Now Active • $250,000 Matching Pool
        </div>
        <h1 className="text-4xl sm:text-6xl font-extrabold tracking-tight text-white leading-tight">
          Democratic Funding for <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-indigo-400">Public Goods</span>
        </h1>
        <p className="text-lg text-gray-400 leading-relaxed">
          Quadratic Funding amplifies grassroots support. The number of unique contributors matters more than the dollar amount of any single contribution.
        </p>
        <div className="flex flex-wrap items-center justify-center gap-4 pt-2">
          <Link href="/donate" className="px-6 py-3 rounded-xl bg-blue-600 hover:bg-blue-500 font-semibold text-white shadow-xl shadow-blue-600/25 transition-all">
            Explore Active Round
          </Link>
          <Link href="/projects" className="px-6 py-3 rounded-xl bg-gray-900 hover:bg-gray-800 font-semibold text-gray-200 border border-gray-800 transition-all">
            Register a Project
          </Link>
        </div>
      </section>

      {/* Protocol Metrics Grid */}
      <section className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {[
          { label: "Total Matching Pool", value: "$1,250,000", change: "+24% from Round 3" },
          { label: "Community Donations", value: "$480,210", change: "12,450 transactions" },
          { label: "Unique Human Donors", value: "8,920", change: "Gitcoin & EAS Verified" },
          { label: "Public Goods Funded", value: "142", change: "Across 4 EVM Rounds" },
        ].map((metric, idx) => (
          <div key={idx} className="p-6 rounded-2xl bg-gray-900/60 border border-gray-800/80 backdrop-blur-sm">
            <div className="text-sm font-medium text-gray-400">{metric.label}</div>
            <div className="text-2xl sm:text-3xl font-bold text-white mt-2">{metric.value}</div>
            <div className="text-xs text-blue-400 mt-1">{metric.change}</div>
          </div>
        ))}
      </section>

      {/* How Quadratic Funding Works */}
      <section className="rounded-3xl border border-gray-800 bg-gray-900/40 p-8 sm:p-12 space-y-8">
        <div className="max-w-2xl">
          <h2 className="text-2xl sm:text-3xl font-bold text-white">How Quadratic Funding Multiplies Impact</h2>
          <p className="text-gray-400 mt-2">
            Instead of 1 dollar = 1 vote, QF calculates matching from the square of the sum of square roots of each individual donation.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          <div className="p-6 rounded-xl bg-gray-950/60 border border-gray-800/60 space-y-3">
            <div className="w-10 h-10 rounded-lg bg-blue-900/50 text-blue-400 font-bold flex items-center justify-center">1</div>
            <h3 className="font-semibold text-white">Verified Unique Donors</h3>
            <p className="text-sm text-gray-400">
              Contributors verify through Gitcoin Passport or EAS attestations, generating cryptographic nullifiers that eliminate Sybil farming.
            </p>
          </div>
          <div className="p-6 rounded-xl bg-gray-950/60 border border-gray-800/60 space-y-3">
            <div className="w-10 h-10 rounded-lg bg-indigo-900/50 text-indigo-400 font-bold flex items-center justify-center">2</div>
            <h3 className="font-semibold text-white">Quadratic Amplification</h3>
            <p className="text-sm text-gray-400">
              Ten contributions of $10 unlock significantly higher matching than a single contribution of $100, prioritizing broad community consensus.
            </p>
          </div>
          <div className="p-6 rounded-xl bg-gray-950/60 border border-gray-800/60 space-y-3">
            <div className="w-10 h-10 rounded-lg bg-purple-900/50 text-purple-400 font-bold flex items-center justify-center">3</div>
            <h3 className="font-semibold text-white">Optimistic Merkle Payouts</h3>
            <p className="text-sm text-gray-400">
              Allocations are computed deterministically off-chain by Rust engines and finalized on-chain through dispute-protected Merkle trees.
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}
