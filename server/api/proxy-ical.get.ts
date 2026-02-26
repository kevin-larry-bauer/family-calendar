export default defineEventHandler(async (event) => {
  const query = getQuery(event);
  const url = query.url as string;

  if (!url) {
    throw createError({ statusCode: 400, statusMessage: 'Missing "url" query parameter' });
  }

  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw createError({
        statusCode: response.status,
        statusMessage: `Upstream calendar returned ${response.status} ${response.statusText}`,
      });
    }

    const body = await response.text();

    // Return raw iCal text
    setResponseHeader(event, 'Content-Type', 'text/calendar; charset=utf-8');
    return body;
  } catch (err: any) {
    if (err.statusCode) throw err;
    throw createError({ statusCode: 502, statusMessage: `Failed to fetch calendar: ${err.message}` });
  }
});
