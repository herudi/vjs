// Credit : https://www.npmjs.com/package/performance-polyfill
const { perf_now } = globalThis.__bootstrap;
const perf = {};
const _entries = [];
const _marksIndex = {};
const _filterEntries = function (key, value) {
  let i = 0, n = _entries.length, result = [];
  for (; i < n; i++) {
    if (_entries[i][key] == value) {
      result.push(_entries[i]);
    }
  }
  return result;
};
const _clearEntries = function (type, name) {
  let i = _entries.length, entry;
  while (i--) {
    entry = _entries[i];
    if (
      entry.entryType == type && (name === void 0 || entry.name == name)
    ) {
      _entries.splice(i, 1);
    }
  }
};
perf.now = () => parseFloat(perf_now() / 1000000);
perf.mark = (name) => {
  const mark = {
    name,
    entryType: "mark",
    startTime: perf.now(),
    duration: 0,
  };
  _entries.push(mark);
  _marksIndex[name] = mark;
};
perf.measure = (name, startMark, endMark) => {
  let startTime, endTime;
  if (endMark !== void 0 && _marksIndex[endMark] === void 0) {
    throw new SyntaxError(
      "Failed to execute 'measure' on 'Performance': The mark '" +
        endMark + "' does not exist.",
    );
  }
  if (startMark !== void 0 && _marksIndex[startMark] === void 0) {
    throw new SyntaxError(
      "Failed to execute 'measure' on 'Performance': The mark '" +
        startMark + "' does not exist.",
    );
  }
  if (_marksIndex[startMark]) startTime = _marksIndex[startMark].startTime;
  else startTime = 0;
  if (_marksIndex[endMark]) endTime = _marksIndex[endMark].startTime;
  else endTime = perf.now();
  _entries.push({
    name: name,
    entryType: "measure",
    startTime: startTime,
    duration: endTime - startTime,
  });
};
perf.getEntriesByType = (v) => _filterEntries("entryType", v);
perf.getEntriesByName = (v) => _filterEntries("name", v);
perf.clearMarks = (v) => _clearEntries("mark", v);
perf.clearMeasures = (v) => _clearEntries("measure", v);

globalThis.performance = perf;
