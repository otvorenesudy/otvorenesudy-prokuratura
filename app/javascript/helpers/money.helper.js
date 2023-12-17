import { values } from "lodash";

const SKK_TO_EUR_BY_YEAR = {
  1993: 37.219,
  1994: 38.086,
  1995: 37.872,
  1996: 39.55,
  1997: 38.372,
  1998: 43.29,
  1999: 42.458,
  2000: 43.996,
  2001: 42.76,
  2002: 41.722,
  2003: 41.161,
  2004: 38.796,
  2005: 37.848,
  2006: 34.573,
  2007: 33.603,
  2008: 30.126,
};

export function convertSkkToEur(skk, year) {
  const denominator = values(SKK_TO_EUR_BY_YEAR).includes(year)
    ? SKK_TO_EUR_BY_YEAR[year]
    : year < 1993
    ? SKK_TO_EUR_BY_YEAR[1993]
    : SKK_TO_EUR_BY_YEAR[2008];

  return Math.round(skk / denominator);
}
