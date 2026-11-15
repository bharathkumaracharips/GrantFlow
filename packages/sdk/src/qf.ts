import { Contribution, MatchingEstimate } from './types.js';

const WAD = 10n ** 18n;

export function sqrtWad(x: bigint): bigint {
  if (x === 0n) return 0n;
  const scaled = x * WAD;
  let z = (scaled + 1n) / 2n;
  let y = scaled;
  while (z < y) {
    y = z;
    z = (scaled / z + z) / 2n;
  }
  return y;
}

export function calculateQuadraticMatching(
  contributions: Contribution[],
  matchingPoolTotal: bigint,
  maxMatchingCapBps: bigint = 2000n // default 20%
): MatchingEstimate[] {
  // Group by project -> identityNullifier
  const projectMap = new Map<bigint, Map<string, bigint>>();

  for (const c of contributions) {
    if (!projectMap.has(c.projectId)) {
      projectMap.set(c.projectId, new Map());
    }
    const idMap = projectMap.get(c.projectId)!;
    const current = idMap.get(c.identityNullifier) ?? 0n;
    idMap.set(c.identityNullifier, current + c.amount);
  }

  const estimates: MatchingEstimate[] = [];
  let totalMatchingDemand = 0n;

  for (const [projectId, idMap] of projectMap.entries()) {
    let directTotal = 0n;
    let sumSqrt = 0n;

    for (const amount of idMap.values()) {
      directTotal += amount;
      sumSqrt += sqrtWad(amount);
    }

    // rawScore = (sumSqrt)^2 in WAD
    const rawScore = (sumSqrt * sumSqrt + (WAD / 2n)) / WAD;
    const matchingDemand = rawScore > directTotal ? rawScore - directTotal : 0n;
    totalMatchingDemand += matchingDemand;

    estimates.push({
      projectId,
      directTotal,
      matchingDemand,
      estimatedMatching: 0n,
      uniqueContributors: idMap.size,
    });
  }

  if (matchingPoolTotal > 0n && totalMatchingDemand > 0n) {
    const maxCap = (matchingPoolTotal * maxMatchingCapBps) / 10000n;
    let distributed = 0n;

    for (const est of estimates) {
      if (est.matchingDemand > 0n) {
        let share = (matchingPoolTotal * est.matchingDemand) / totalMatchingDemand;
        if (share > maxCap && maxCap > 0n) {
          share = maxCap;
        }
        est.estimatedMatching = share;
        distributed += share;
      }
    }

    // Remainder dust allocation
    if (distributed < matchingPoolTotal && estimates.length > 0) {
      estimates[0].estimatedMatching += matchingPoolTotal - distributed;
    }
  }

  return estimates;
}
