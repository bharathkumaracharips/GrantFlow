export default function RoundsPage() {
  const rounds = [
    {
      id: 4,
      title: "Round 4 — EVM Infrastructure & Developer Tools",
      status: "Active",
      statusColor: "bg-emerald-950/60 text-emerald-400 border-emerald-800",
      matchingPool: "$250,000",
      directDonations: "$68,400",
      projectsCount: 28,
      endsIn: "4 days, 12 hours",
      token: "USDC",
    },
    {
      id: 3,
      title: "Round 3 — Zero Knowledge & Privacy Protocols",
      status: "Finalized",
      statusColor: "bg-purple-950/60 text-purple-400 border-purple-800",
      matchingPool: "$350,000",
      directDonations: "$114,200",
      projectsCount: 42,
      endsIn: "Disbursed",
      token: "DAI",
    },
    {
      id: 5,
      title: "Round 5 — Climate & Open Science",
      status: "Registration",
      statusColor: "bg-blue-950/60 text-blue-400 border-blue-800",
      matchingPool: "$150,000",
      directDonations: "$0",
      projectsCount: 14,
      endsIn: "Starts in 6 days",
      token: "USDC",
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-white">Funding Rounds</h1>
        <p className="text-gray-400 text-sm mt-1">Review active, upcoming, and completed quadratic funding rounds.</p>
      </div>

      <div className="space-y-4">
        {rounds.map((round) => (
          <div key={round.id} className="p-6 rounded-2xl bg-gray-900/60 border border-gray-800 flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div className="space-y-2">
              <div className="flex items-center gap-3">
                <span className={`text-xs font-semibold px-2.5 py-0.5 rounded-full border ${round.statusColor}`}>
                  {round.status}
                </span>
                <span className="text-xs text-gray-400">Currency: {round.token}</span>
              </div>
              <h2 className="text-xl font-bold text-white">{round.title}</h2>
              <p className="text-xs text-gray-400">Timeline: {round.endsIn} • {round.projectsCount} registered projects</p>
            </div>

            <div className="flex items-center gap-8 border-t md:border-t-0 border-gray-800 pt-4 md:pt-0">
              <div>
                <div className="text-xs text-gray-500">Matching Pool</div>
                <div className="text-lg font-bold text-emerald-400">{round.matchingPool}</div>
              </div>
              <div>
                <div className="text-xs text-gray-500">Direct Raised</div>
                <div className="text-lg font-bold text-white">{round.directDonations}</div>
              </div>
              <button className="px-5 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-medium text-sm transition-all whitespace-nowrap">
                View Round
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
