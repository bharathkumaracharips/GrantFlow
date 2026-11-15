export default function ProjectsPage() {
  const sampleProjects = [
    {
      id: 1,
      title: "Zero-Knowledge State Compression",
      category: "Privacy & ZK",
      description: "Scalable zk-SNARK rollup state compression reducing EVM storage proof sizes by 80%.",
      directDonations: "$4,250",
      matchingEstimate: "$14,800",
      contributors: 142,
      owner: "0x391...921",
    },
    {
      id: 2,
      title: "Solidity Invariant Fuzzer",
      category: "Developer Tools",
      description: "Stateful property-based fuzz testing framework with symbolic execution support for Foundry.",
      directDonations: "$2,100",
      matchingEstimate: "$9,400",
      contributors: 98,
      owner: "0x781...310",
    },
    {
      id: 3,
      title: "Decentralized Climate Registry",
      category: "Open Science",
      description: "On-chain ecological impact telemetry and verified carbon offset oracle data feeds.",
      directDonations: "$1,850",
      matchingEstimate: "$6,200",
      contributors: 76,
      owner: "0x442...551",
    },
  ];

  return (
    <div className="space-y-8">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 border-b border-gray-800 pb-6">
        <div>
          <h1 className="text-3xl font-bold text-white">Explore Projects</h1>
          <p className="text-gray-400 text-sm mt-1">Discover and fund eligible public goods projects in active rounds.</p>
        </div>
        <button className="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-medium text-sm transition-all shadow-lg shadow-blue-600/20">
          + Register New Project
        </button>
      </div>

      <div className="grid md:grid-cols-3 gap-6">
        {sampleProjects.map((project) => (
          <div key={project.id} className="p-6 rounded-2xl bg-gray-900/60 border border-gray-800 hover:border-gray-700 transition-all flex flex-col justify-between">
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-blue-950/60 text-blue-400 border border-blue-900/60">
                  {project.category}
                </span>
                <span className="text-xs text-gray-500 font-mono">By {project.owner}</span>
              </div>
              <h3 className="text-lg font-bold text-white">{project.title}</h3>
              <p className="text-sm text-gray-400 line-clamp-3">{project.description}</p>
            </div>

            <div className="pt-6 border-t border-gray-800/80 mt-6 space-y-4">
              <div className="flex justify-between text-xs">
                <span className="text-gray-400">Direct Raised: <strong className="text-white">{project.directDonations}</strong></span>
                <span className="text-gray-400">Estimated Match: <strong className="text-emerald-400">{project.matchingEstimate}</strong></span>
              </div>
              <div className="text-xs text-blue-400 font-medium">
                {project.contributors} unique verified donors
              </div>
              <button className="w-full py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 font-semibold text-white text-sm transition-all">
                Donate & Match
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
