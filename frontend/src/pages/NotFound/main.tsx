import { Link } from 'react-router-dom';

const NotFoundPage = () => {
  return (
    <div className="flex flex-col items-center justify-center h-full text-center">
      <h1 className="text-6xl font-bold text-gray-800">404</h1>
      <p className="mt-4 text-xl text-gray-600">Page Not Found</p>
      <p className="mt-2 text-gray-500">The page you are looking for does not exist.</p>
      <Link to="/" className="mt-6 px-4 py-2 text-white bg-blue-500 rounded hover:bg-blue-600">
        Go to Homepage
      </Link>
    </div>
  );
};

export default NotFoundPage;
