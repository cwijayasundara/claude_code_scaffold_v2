"""Entry point for the application."""

import logging
import sys

logger = logging.getLogger(__name__)


def main() -> None:
    """Run the application."""
    logging.basicConfig(level=logging.INFO)
    logger.info("Hello, world! Replace this with your application logic.")


if __name__ == "__main__":
    main()
    sys.exit(0)
