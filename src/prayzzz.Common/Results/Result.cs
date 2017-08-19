﻿using System;

namespace prayzzz.Common.Results
{
    public interface IResult<out TData>
    {
        TData Data { get; }

        ErrorType ErrorType { get; }

        Exception Exception { get; }

        bool IsError { get; }

        bool IsSuccess { get; }

        string Message { get; }

        object[] MessageArgs { get; }
    }

    public abstract class Result<TData> : Result, IResult<TData>
    {
        protected Result()
        {
        }

        /// <summary>
        ///     Creates a result from the given result
        /// </summary>
        protected Result(Result result) : base(result)
        {
        }

        public TData Data { get; protected set; }
    }

    public abstract class Result
    {
        protected Result()
        {
            ErrorType = ErrorType.None;
            Message = string.Empty;
            MessageArgs = Array.Empty<object>();
        }

        /// <summary>
        ///     Creates a result from the given result
        /// </summary>
        protected Result(Result result) : this()
        {
            ErrorType = result.ErrorType;
            Message = result.Message;
            MessageArgs = result.MessageArgs;
        }

        public ErrorType ErrorType { get; protected set; }

        public Exception Exception { get; protected set; }

        public bool IsError => ErrorType != ErrorType.None;

        public bool IsSuccess => ErrorType == ErrorType.None;

        public string Message { get; protected set; }

        public object[] MessageArgs { get; protected set; }

        public string ToMessageString()
        {
            return string.Format(Message, MessageArgs);
        }
    }
}